//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;


/**
 * @dev This contract is responsible for managing the users of this system,
 * users can be defined, their activity status can be adjusted and various roles
 * can be assigned to them.
 *
 *
 * Note that before deploying this contract, you must specify the different
 * roles in the contract code and manage the initial settings of each function.
 */

 contract accessControl {
    /*
     * @dev "Roles" mapping, record  roles of any User
     * **FID => User => bool**
     */
    mapping(uint8 => mapping(address => bool)) public access;

    /*
     * @dev "Users" mapping, record Users for WhiteList
     * **User => bool**
     */
    mapping(address => bool) public users;

    /*
     * @dev "Status" mapping, record  Staus of Users, if false, User is disable in our system
     * **User => bool**
     */
    mapping(address => bool) public status;


    bool public limitation;

    /*
     * Define Roles
     */
    // bytes32 constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // bytes32 constant USER = keccak256(abi.encodePacked("USER"));
    // bytes32 constant ACC = keccak256(abi.encodePacked("ACC"));
    // bytes32 constant HR = keccak256(abi.encodePacked("HR"));

    /*
     * @Dev "Only_Role" modifier, check roles of user, if User permissioned for "_role" Role,
     * and be in "Users" Mapping, modifier will be true.
     */
    modifier _checkAccess(uint8 _FID) {
        require(access[_FID][tx.origin], "Not Authorized");
        require(status[tx.origin]);
        _;
    }

    // modifier onlyDefinedUser(address _address) {
    //     require(users[_address],"undefined user");
    //     _;
    // }

    /*
     * @Dev constructor will set ADMIN Config
     * Set ADMIN Role for Deployer(ADMIN Should have access to Accounting)(the base role is USER)
     * Define ADMIN User in "Users" Mapping
     */
    constructor() {

        users[msg.sender] = true;
        for (uint8 index = 0; index < 14; index++) {
             access[index][msg.sender] = true;
        }
        status[msg.sender] = true;
        defineUser(address(0));

        limitation = true;

    }

    /*
     * @Dev its  internal function
     * Grant a role to user
     */
    function _grantAccess(uint8 _FID, address _account) internal {
        require(checkUser(_account),"Not defined User");
        access[_FID][_account] = true;
    }

    /*
     * @Dev its  external function
     * Grant a role to user with "_Grant_Role" Function
     * Just ADMIN Role can Use it
     */
    function grantAccess(uint8[] memory _FIDs, address _account)
        external
        _checkAccess(1)
    {
        for (uint256 index = 0; index < _FIDs.length; index++) {
            _grantAccess(_FIDs[index], _account);
        }
    }

    /*
     * @Dev its  external function
     * Revoke a role from user
     * Just ADMIN Role can Use it
     */
    function revokeAccess(uint8[] memory _FIDs, address _account)
        external
        _checkAccess(2)
    {
        require(checkUser(_account),"Not defined User");
        for (uint256 index = 0; index < _FIDs.length; index++) {
            access[_FIDs[index]][_account] = false;
        }
    }

    // @Dev if user defined and dont be ADMIN can change User status
    function setStatus(address _address, bool _status)
        public
        _checkAccess(3)
    {
        require(_address != msg.sender,"input address is admin address");
        require(users[_address],"undefined user");
        status[_address] = _status;
    }

    // @Dev if User didnt Define can define it(The roles will be deafault USER and Status will be False(it should turn to true))
    function defineUser(address _address) public _checkAccess(4) returns(bool) {
        require(!users[_address],"defined user");
        users[_address] = true;
        setStatus(_address, true);
        // for (uint256 index = 0; index < 5; index++) {
        //     _grantAccess(1, _address);
        // }
        return true;
    }

    // @Dev This function checks whether a user has a role in the system or not

    // function checkRole(bytes32 _role,address _address)public view returns(bool) {
    //     return roles[_role][_address]; 
    //   }
      
      // @Dev This function checks whether this user is defined in the system or not
    function checkUser(address _address)public view returns(bool) {
        return users[_address]; 
      }

      // @Dev This function checks whether this user is active in the system or not
    function checkStatus(address _address)public view returns(bool) {
        return status[_address]; 
      }

    
        
    function checkAccess(uint8 _FID) public view returns(bool){
        require(access[_FID][tx.origin], "Not Authorized");
        require(status[tx.origin],"deactive user"); 
        return true;
    }

    function toggleLimitation() public _checkAccess(14) {
        limitation = ! limitation;
    }
}
