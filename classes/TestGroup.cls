public class TestGroup {
public static void showAccountShares(ID AccountID) {
		ID roleID;
		String str;
		UserRole role;
		List<ID> roleIDs;
		ID UserOrGroupId;
		Group shareGroup;
		Map<ID, UserRole> roles;
		Map<ID, Group> shareGroups;
		List<AccountShare> accShares;
 
		// Find Account Shares For Account
		accShares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel, RowCause FROM AccountShare WHERE AccountId = :AccountID AND isDeleted = false];
 
		// Find groups for Account Share
		shareGroups = new Map<ID, Group>([SELECT Id, Name, RelatedId, Type FROM Group WHERE Id IN (SELECT UserOrGroupId FROM AccountShare WHERE AccountId = :AccountID)]); 
 
		// Get Role IDs
		roleIDs = new List<ID>();
		for (Group shareGroup1 : shareGroups.values()) {
			roleIDs.add(shareGroup1.RelatedId);
		}
 
		// Find roles for groups
		roles = new Map<ID, UserRole>([SELECT Id,Name,ParentRoleId,PortalAccountId,PortalAccountOwnerId,PortalRole,PortalType FROM UserRole WHERE id IN :roleIDs]);
 
		// Dump data
		str = '';
		str += '\r\n';
		str += '\r\n' + 'Account: ' + AccountID;
		for (AccountShare  accShare : accShares) {
 
			UserOrGroupId = accShare.UserOrGroupId;
			shareGroup = shareGroups.get(UserOrGroupId);
			if (shareGroup == null) {
				continue;
			}
 
			roleID = shareGroup.RelatedId;
			role = roles.get(roleID);
			if (role == null) {
				continue;
			}
			
			str += '\r\n' + '================================================';
			str += '\r\n' + 'UserOrGroupId: ' + UserOrGroupId;
			str += '\r\n' + 'AccountAccessLevel: ' + accShare.AccountAccessLevel;
			str += '\r\n' + 'RowCause: ' + accShare.RowCause;
			str += '\r\n' + 'Group Name: ' + shareGroup.Name;
			str += '\r\n' + 'Group Type: ' + shareGroup.Type;
			str += '\r\n' + 'Role Name: ' + Role.Name;
			str += '\r\n' + 'Role PortalAccountId: ' + Role.PortalAccountId;
			str += '\r\n' + 'Role PortalRole: ' + Role.PortalRole;
			str += '\r\n' + 'Role PortalType: ' + Role.PortalType;
		}
		System.debug(str);
	}
}