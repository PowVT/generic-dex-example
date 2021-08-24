pragma solidity ^0.6.6;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Adaptive is ERC20 {
  constructor() ERC20("Adaptive","ADP") public {
      _mint(msg.sender,1000*10**18);
  }
}
