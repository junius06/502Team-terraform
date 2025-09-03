variable "s3_info" {
  type = map(object({
    s3_kms_arn     = string
    s3_versioning  = string
    s3_tags        = map(string)
    s3_object_lock = string
    s3_logging = object({
      s3_logging_target                   = string
      s3_logging_target_prefix            = string
      s3_logging_target_object_key_format = string
      s3_logging_partitioned_prefix_type  = string
    })
    s3_lifecycle = list(object({
      s3_lifecycle_rule_name   = string
      s3_lifecycle_rule_status = string
      s3_lifecycle_rule_filter = list(object({
        object_size_greater_than = string
        object_size_less_than    = string
        prefix                   = string
        tags                     = map(string)
      }))
      s3_lifecycle_rule_transition = list(object({
        days          = string
        storage_class = string
      }))
      s3_lifecycle_rule_expiration = object({
        days = string
      })
    }))
    s3_policy = any
  }))
}