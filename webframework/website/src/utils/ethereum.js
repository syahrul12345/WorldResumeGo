import contractInfo from "../../../../build/contracts/PortfolioFactory.json";
import portFolio from "../../../../build/contracts/Portfolio.json";
import employer from "../../../../build/contracts/Employer.json";
export const getContractInfo = async () => {
  const portFolioABI = contractInfo.abi;
  const deployedAddress = getNetworkId(contractInfo);
  return { portFolioABI, deployedAddress };
};
export const getPortfolioInfo = async () => {
  const portFolioABI = portFolio.abi;
  return { portFolioABI };
};

export const getEmployerTracker = async () => {
  const employerTrackerABI = employer.abi;
  const deployedAddress = getNetworkId(employer);
  return { employerTrackerABI, deployedAddress };
};

const getNetworkId = contractInfo => {
  for (var i in contractInfo.networks) {
    return contractInfo.networks[i].address;
  }
};
