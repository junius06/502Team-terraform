# Auto deploy with Terraform

## Branch descriptions
### main
1. aws credential 에 대한 설명  
2. github actions 를 이용한 terraform PR plan

### dev/stg/prd
1. 브랜치에 따른 workspace 환경 분리
<br>

## Architect
1. 메인브랜치에서 Actions 실행  
2. Actions 실행 전 드롭다운으로 선택하는 env, region에 따라 배포할 workspace & tfvars 지정  
3. 해당 workspace에서 init, plan, apply 가 순차적으로 진행  
<br>

**이 내용을 아키텍처로 그려보자**