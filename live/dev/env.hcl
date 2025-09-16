locals {
  env = "dev"

  # 쉘/CI에서 넣어줄 값. 미지정 시 "1"로 가정
  region_choice = get_env("REGION_CHOICE")

  region_map = {
    "eu" = "eu-west-1"
    "us" = "us-west-2"
  }

  # 매핑 실패 시 에러 발생 (fallback 제거)
  region = lookup(
    local.region_map,
    local.region_choice,
    error("❌ REGION_CHOICE 값이 잘못되었습니다. 반드시 REGION_CHOICE=eu 또는 REGION_CHOICE=us 를 입력하세요.")
  )
}