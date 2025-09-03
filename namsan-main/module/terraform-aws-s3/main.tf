###########################
# S3 Bucket
###########################
resource "aws_s3_bucket" "this" {
  for_each = var.s3_info

  bucket = each.value.s3_tags.Name
  tags   = each.value.s3_tags
}

###########################
# S3 OwnerShip
###########################
resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = var.s3_info

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

###########################
# S3 Server Side Encryption
###########################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" { # 암호화 부분
  for_each = { for k, v in var.s3_info : k => v if v.s3_kms_arn != "" }

  bucket = aws_s3_bucket.this[each.key].id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = each.value.s3_kms_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

###########################
# S3 Versioning
###########################
resource "aws_s3_bucket_versioning" "this" { #버전 설정
  for_each = var.s3_info

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = each.value.s3_versioning
  }
}

###########################
# S3 Oject Locking
###########################
resource "aws_s3_bucket_object_lock_configuration" "this" { #객체 암호화
  for_each            = { for k, v in var.s3_info : k => v if v.s3_object_lock == "Enabled" }
  bucket              = aws_s3_bucket.this[each.key].id
  object_lock_enabled = each.value.s3_object_lock

  depends_on = [aws_s3_bucket_versioning.this] #버전 관리 의존성 필요
}

###########################
# S3 Policy
###########################
resource "aws_s3_bucket_policy" "this" { #객체 암호화
  for_each = { for k, v in var.s3_info : k => v if v.s3_policy != {} }

  bucket = aws_s3_bucket.this[each.key].id
  policy = jsonencode(each.value.s3_policy) #json 형식으로 인코딩
}

###########################
# S3 Logging
###########################
resource "aws_s3_bucket_logging" "this" {
  for_each = { for k, v in var.s3_info : k => v if v.s3_logging.s3_logging_target != "" }

  bucket        = aws_s3_bucket.this[each.key].id
  target_bucket = each.value.s3_logging.s3_logging_target
  target_prefix = each.value.s3_logging.s3_logging_target_prefix

  dynamic "target_object_key_format" {
    for_each = try([each.value.s3_logging.s3_logging_target_object_key_format], [])

    content {
      dynamic "partitioned_prefix" {
        for_each = strcontains(each.value.s3_logging.s3_logging_target_object_key_format, "partitioned_prefix") ? [true] : []

        content { partition_date_source = try(each.value.s3_logging.s3_logging_partitioned_prefix_type, null) }
      }

      dynamic "simple_prefix" {
        for_each = strcontains(each.value.s3_logging.s3_logging_target_object_key_format, "simple_prefix") ? [true] : []

        content {}
      }
    }
  }
}

###########################
# S3 LifeCycle
###########################
# https://github.com/hashicorp/terraform-provider-aws/pull/39492 -> 객체 최소 크기 128kb
# https://github.com/hashicorp/terraform-provider-aws/issues/23352 -> plan 지연 이슈(확인 필요)
# https://github.com/hashicorp/terraform-provider-aws/issues/37241 -> 하나의 버킷에 다수(multiple) aws_s3_bucket_lifecycle_configuration 선언 불가
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = { for k, v in var.s3_info : k => v if length(v.s3_lifecycle) > 0 }

  bucket = aws_s3_bucket.this[each.key].id

  dynamic "rule" {
    for_each = each.value.s3_lifecycle

    content {
      id     = rule.value["s3_lifecycle_rule_name"]
      status = rule.value["s3_lifecycle_rule_status"]

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.s3_lifecycle_rule_filter]), [])) == 0 ? [true] : []

        content {}
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.s3_lifecycle_rule_filter]), []) : v if max(length(keys(v)), length(try(rule.value.s3_lifecycle_rule_filter.tags, rule.value.s3_lifecycle_rule_filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }

      # Single block - expiration
      dynamic "expiration" {
        for_each = rule.value.s3_lifecycle_rule_expiration.days != "" ? flatten([rule.value.s3_lifecycle_rule_expiration]) : []

        content {
          days = try(expiration.value.days, null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = length(rule.value.s3_lifecycle_rule_transition) > 0 ? flatten([rule.value.s3_lifecycle_rule_transition]) : []

        content {
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}