pragma solidity = 0.5.9;

contract Employer {
	mapping(address => bytes32) employers;
	address[] public addresses;
	address public owner;
	uint private count;
	constructor() public {
		owner = msg.sender;
		count = 0;
	}

	function register(bytes32 _name) external {
		require(employers[msg.sender] == 0);
		addresses.push(msg.sender);
		employers[msg.sender] = _name;
		
	}
	function getAllEmployers() external view returns (bytes32[] memory,address[] memory) {
		bytes32[] memory nameResults = new bytes32[](addresses.length);
		address[] memory addressResults = new address[](addresses.length);
		for(uint i =0;i<addresses.length;i++){
			nameResults[i] = employers[addresses[i]];
			addressResults[i] = addresses[i];
		}
		return (nameResults,addressResults);
	}

}