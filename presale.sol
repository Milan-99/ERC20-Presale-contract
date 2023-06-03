// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function ownable() public{
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}




interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
/**
 * @title ProofPresale 
 * ProofPresale allows investors to make
 * token purchases and assigns them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
 
contract PresaleContract is Ownable{
  using SafeMath for uint256;

  IERC20 public token;

  uint256 public weiRaised;

  uint256 public minInvestment;

  uint256 public rate;

  mapping (address => bool) public whitelisted;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  constructor() public {
    owner=msg.sender;
  }

  function initialize(IERC20 _token,uint256 _minInvestment, uint256 _rate) public onlyOwner{
    require(_minInvestment >= 0);
    token=_token;   // Presale token
    rate = _rate;  //Rate on ether unit 
    minInvestment = _minInvestment;  //minimum investment in wei  (=10 ether)
  }

  function setwhitelist(address[] memory _address) public onlyOwner{
      for (uint i=0;i< _address.length;i++){
          whitelisted[_address[i]]=true;
      }
  }


  // fallback function to buy tokens
  receive () external  payable {
    require(whitelisted[msg.sender]==true,"Not a whitelisted address+");
    buyTokens(msg.sender);
  }


  function buyTokens(address beneficiary) public payable {
    require(validPurchase());

    uint256 weiAmount = msg.value;
    // update weiRaised
    weiRaised = weiRaised.add(weiAmount);
    // compute amount of tokens created
    uint256 tokens = weiAmount.mul(rate);

    token.transfer( beneficiary,tokens);
  }

  // return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool notSmallAmount = msg.value >= minInvestment;
    return notSmallAmount;
  }

  function finalwithdraw() public payable onlyOwner{
    uint256 amount = address(this).balance;
    require(amount > 0, "Nothing to withdraw; contract balance empty");
    msg.sender.transfer(amount);
  }
}
