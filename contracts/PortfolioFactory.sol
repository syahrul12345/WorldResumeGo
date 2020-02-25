pragma solidity = 0.5.9;

contract Portfolio {
	address public owner;
	struct job {
		bytes32 companyName;
		address companyAddress;
		bytes32 position;
		uint start;
		uint end;
		bool verified;
	}
	event Verified (
		bytes32 jobId
	);
	uint256 private count;
	bytes32[] private jobIDs;
	mapping(bytes32 => job) jobMapping;
	
	string public name;
	string public blurb;
	
	constructor(address _owner,
        	    string memory _name,
        	    string memory _blurb,
        	    bytes32[] memory _companyNames,
        	    address[] memory _companyAddress,
        	    bytes32[] memory _positions,
        	    uint[] memory _startTimes,
        	    uint[] memory _endTimes) public {
	            count = 0;
		        owner = _owner;
		        name =_name;
		        blurb =_blurb;
		        for(uint i=0;i<_companyNames.length;i++){
                    addJob(_companyNames[i],_companyAddress[i],_positions[i],_startTimes[i],_endTimes[i]);
		        }
		        
	}
	
	function getDetails() external returns(string memory, string memory) {
		return(name,blurb);
	}

	function addJob(bytes32 _companyName,address _companyAddress,bytes32 _position,uint _start,uint _end) public {
		bytes32 id = keccak256(abi.encodePacked(_companyName,_position,_start,_end,count));
		jobIDs.push(id);
		count++;
		jobMapping[id].companyName = _companyName;
		jobMapping[id].companyAddress = _companyAddress;
		jobMapping[id].position = _position;
		jobMapping[id].start = _start;
		jobMapping[id].end = _end;
		jobMapping[id].verified = false;
	}
	function getJobById(bytes32 _id) external view returns(bytes32,address,bytes32,uint,uint,bool,bytes32) {
		return(jobMapping[_id].companyName,jobMapping[_id].companyAddress,jobMapping[_id].position,jobMapping[_id].start,jobMapping[_id].end,jobMapping[_id].verified,_id);
	}
	function getAllJobId() external view returns (bytes32[] memory) {
		return jobIDs;
	}
	function verify(bytes32 _id) external {
		//only the company can send
		require(jobMapping[_id].companyAddress == msg.sender);
	    jobMapping[_id].verified = true;
	    emit Verified(_id);
	} 

}

contract PortfolioFactory {
	mapping (address => address) ownerToPortFolio;

	constructor() public {

	}
	
	function createPortfolio(
	    address _owner,
	    string memory _name,
	    string memory _blurb,
	    bytes32[] memory _companyNames,
	    address[] memory _companyAddress,
	    bytes32[] memory _positions,
	    uint[] memory _startTimes,
	    uint[] memory _endTimes) public {
		Portfolio p = new Portfolio(_owner,_name,_blurb,_companyNames,_companyAddress,_positions,_startTimes,_endTimes);
		ownerToPortFolio[_owner] = address(p);
	}
	function getPortfolioAddress() public view returns (address) {
		return ownerToPortFolio[tx.origin];
	}
	function addJob(address _owner, bytes32 _companyName, address _companyAddress,bytes32 _position,uint _start,uint _end) external {
		Portfolio p = Portfolio(ownerToPortFolio[_owner]);
		p.addJob(_companyName,_companyAddress,_position,_start,_end);
	}
	function getAllJobId(address _owner) external view returns (bytes32[] memory) {
		Portfolio p = Portfolio(ownerToPortFolio[_owner]);
		return p.getAllJobId();
	}
	function getJobById(address _owner,bytes32 _id) external view returns(bytes32,address,bytes32,uint,uint,bool,bytes32) {
		Portfolio p = Portfolio(ownerToPortFolio[_owner]);
		return p.getJobById(_id);
	}
	function  getDetails(address _owner) external returns(string memory, string memory) {
		Portfolio p = Portfolio(ownerToPortFolio[_owner]);
		return p.getDetails();
	}

}