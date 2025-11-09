Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All","Policy.Read.All","Policy.ReadWrite.ConditionalAccess"

# 삭제 금지 사용자 목록
# 삭제가 금지된 사용자 목록입니다. Domain.com은 테넌트의 도메인입니다.
$excludedUsers = @(
    "admin@Domain.com",
    "MngEnvAdmin@Domain.com"
)

# 사용자 삭제
# Global Admin을 제외한 모든 사용자 삭제
$users = Get-MgUser -All
foreach ($user in $users) {
    if ($excludedUsers -notcontains $user.UserPrincipalName) {
        Write-Host "Deleting user: $($user.UserPrincipalName)"
        Remove-MgUser -UserId $user.Id -Confirm:$false
    }
}

# 삭제된 사용자 완전 삭제
$deletedUsers = Get-MgDirectoryDeletedUser -All
foreach ($user in $deletedUsers) {
    Write-Host "Permanently deleting user: $($user.UserPrincipalName)"
    Remove-MgDirectoryDeletedItem -DirectoryObjectId $user.Id
}

Write-Host "모든 사용자가 완전 삭제되었습니다."

# 그룹 삭제
$groups = Get-MgGroup -All
foreach ($group in $groups) {
    Write-Host "Deleting group: $($group.DisplayName)"
    Remove-MgGroup -GroupId $group.Id -Confirm:$false
}

# 삭제된 그룹 완전 삭제
$deletedGroups = Get-MgDirectoryDeletedGroup -All
foreach ($group in $deletedGroups) {
    Write-Host "Deleting group: $($group.DisplayName)"
    Remove-MgDirectoryDeletedItem -DirectoryObjectId $group.Id
}

Write-Host "모든 그룹이 완전 삭제되었습니다."

# 기본 Conditional Access Policy 비활성화
# MFA를 요구하는 정책을 비활성화하기 위함입니다.
$policies = Get-MgIdentityConditionalAccessPolicy -All
foreach ($policy in $policies) {
    Write-Host "Disabling Conditional Access Policy: $($policy.DisplayName)"
    Update-MgIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $policy.Id -State "disabled"
}

Write-Host "모든 Conditional Access Policy가 비활성화되었습니다."
