// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.6;

/** 
 * @title MVdex
 * @dev Implements a 'minimum viable' decentralized exchange.
 */
 
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 
contract dex {
    
    using SafeMath for uint256; // Over/underflow
    
    IERC20 Adaptive;            // ERC20 interface
    
    address public summoner;    // To be set in the 'init' call.
    
    constructor(address _summoner) public {   // Summoner immutable
        summoner = _summoner;
    }
    
    uint256 public totalLiquidity;      //
    
    mapping (address => uint256) public liquidity;      //
    
    
    /** 
     * @dev Initialized DEX with tokens as well as connect to the token's ERC interface.
     * @param tokens, token_addr
     */
    function init(uint256 tokens, address token_addr) public payable returns (uint256) {
      //require(msg.sender == summoner, "SUMMONER ONLY");
      require(totalLiquidity==0,"DEX:init - already has liquidity");
      Adaptive = IERC20(token_addr);
      totalLiquidity = address(this).balance;
      liquidity[msg.sender] = totalLiquidity;
      require(Adaptive.transferFrom(msg.sender, address(this), tokens));
      return totalLiquidity;
    }
    
    /** 
     * @dev Ratio of the resulting output asset based on the amount of input asset.
     * @param input_amount, input_reserve, output_reserve
     */
    function price(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) public pure returns (uint256) {
      uint256 input_amount_with_fee = input_amount.mul(997);
      uint256 numerator = input_amount_with_fee.mul(output_reserve);
      uint256 denominator = input_reserve.mul(1000).add(input_amount_with_fee);
      return numerator / denominator;
    }
    
    /** 
     * @dev Convert base currency to tokens. 
     */
    function ethToToken() public payable returns (uint256) {
      uint256 token_reserve = Adaptive.balanceOf(address(this));
      uint256 tokens_bought = price(msg.value, address(this).balance.sub(msg.value), token_reserve);
      require(Adaptive.transfer(msg.sender, tokens_bought));
      return tokens_bought;
    }
    
    /** 
     * @dev Convert tokens to base currency.
     * @param tokens Number of tokens to conver to Eth.
     */
    function tokenToEth(uint256 tokens) public returns (uint256) {
      uint256 token_reserve = Adaptive.balanceOf(address(this));
      uint256 eth_bought = price(tokens, token_reserve, address(this).balance);
      payable(msg.sender).transfer(eth_bought);
      require(Adaptive.transferFrom(msg.sender, address(this), tokens));
      return eth_bought;
    }
    
    /** 
     * @dev Provide liquidity to the dex.
     */
    function deposit() public payable returns (uint256) {
      uint256 eth_reserve = address(this).balance.sub(msg.value);
      uint256 token_reserve = Adaptive.balanceOf(address(this));
      uint256 token_amount = (msg.value.mul(token_reserve) / eth_reserve).add(1);
      uint256 liquidity_minted = msg.value.mul(totalLiquidity) / eth_reserve;
      liquidity[msg.sender] = liquidity[msg.sender].add(liquidity_minted);
      totalLiquidity = totalLiquidity.add(liquidity_minted);
      require(Adaptive.transferFrom(msg.sender, address(this), token_amount));
      return liquidity_minted;
    }
    
    /** 
     * @dev Remove liquidity from dex.
     * @param amount Withdrawl amount
     */
    function withdraw(uint256 amount) public returns (uint256, uint256) {
      uint256 token_reserve = Adaptive.balanceOf(address(this));
      uint256 eth_amount = amount.mul(address(this).balance) / totalLiquidity;
      uint256 token_amount = amount.mul(token_reserve) / totalLiquidity;
      liquidity[msg.sender] = liquidity[msg.sender].sub(eth_amount);
      totalLiquidity = totalLiquidity.sub(eth_amount);
      payable(msg.sender).transfer(eth_amount);
      require(Adaptive.transfer(msg.sender, token_amount));
      return (eth_amount, token_amount);
    }
}