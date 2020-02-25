pragma solidity = 0.5.9;

contract PortfolioTest {
	string private name;
	bytes32 private blurb;
	address private owner;

	constructor(string memory _name,bytes32 _blurb) public {
		owner = msg.sender;
		name = _name;
		blurb = _blurb;
	}

	modifier isOwner() {
		require(msg.sender == owner);
		_;
	}
	
	
	function getName() public view returns(string memory) {
		return name;
	}
	function getBlurb() public view returns(bytes32) {
		return blurb;
	}


}