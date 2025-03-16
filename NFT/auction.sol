// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "@openzeppelin/contracts/interfaces/IERC721.sol";
contract Auction {
    event Strat();
    event Bid(address indexed  sender,uint price); // تعریف ایونت برای افراد پیشنهاد دهنده خرید 
    event Withraw(address indexed bidder,uint price); // ایونت برداشت پول 
    event End(address winner , uint price); // پایان حراج و پیدا کردن ادرس برنده و یا خریدار
  
  IERC721 public nft; // تعریف  ان اف تی
  uint public  nftId; // ای دی
  address payable  public seller; // ادرس فروشنده
  uint endAt; // مدت زمان پایا یافتن حراج
  bool public started; // زمان شروع حراج
  bool public ended; // زمان پایان حراج
  address public highOrderAddress; // ادرس بالاترین پیشنهاد دهنده
  uint public highOrder; // بالا ترین مقدار پیشنهاد شده
  mapping (address => uint) public orders; // این مپینگ بالا ترین مقدار پیشنهادی را بر میگرداند 

constructor (address _nft,uint _nftId, uint _startedorders){ // مقادیر ورودی کانستراکتور را مقدار دهی می کنیم
  nft = IERC721(_nft);
  nftId = _nftId;
  seller = payable(msg.sender);
  highOrder = _startedorders;
}
function strat() external  { //یک فانکشن برای شروع حراج می کنیم
    require(!started,"already start...."); // مشخص می کنیم که استارت شده باشد
    require(msg.sender == seller , "not seller"); // مشخص میکنیم که شخص برابر با شخص فروشنده باشد
    nft.transferFrom(msg.sender , address(this), nftId);// مقدار ترنسفور فورم از کتابخانه ای است که بالا تعریف کردیم  
    started = true;  // مقدار استارت را ترو می کنیم به معنی اینکه حراج شروع شده
    endAt = block.timestamp + 1 days; // زمان پایان 
    emit Strat();  // ایونت را امیت یا پر می کنیم

}
function order() external payable  {
    require(started , "not started"); // تعریف می کنیم که شرط حتما شروع شده باشد
    require(block.timestamp < endAt  ); // بررسی پایان یافتن حراج
    require(msg.value > highOrder); //بررسی اینکه مقدار پیشنهاد بالا ر از مابقی پیشنهاد ها باشد
    if  (highOrderAddress != address(0)){ // شرط می گذاریم که اگر کسی که بالاترین پیشنهاد را گذاشته ادرسش برابر با صفر نبود
      orders[highOrderAddress] += highOrder; //مپینگ مربوط به پیدا کننده بالا ترین فرد پیشنهاد دهنده را به ان می دهیم
    }

    highOrderAddress = msg.sender;  // ادرس 
    highOrder = msg.value; // مقدار

    emit  Bid(msg.sender , msg.value); // امیت را پر می کنیم

}
function withdraw() external  {
    uint balance = orders[msg.sender]; // مقدار پیشنهادی را دریافت می کنیم
    orders[msg.sender] = 0; 
    payable (msg.sender).transfer(balance);//این کد پول شخصی که برنده نشده را برمی گرداند
    emit Withraw(msg.sender, balance); // امیت را پر میکنیم

}   
function end() external  {
    require(started,"not started"); // حراج استارت باشد
    require(block.timestamp >= endAt,"not ended"); // تمام نشده باشد
    require(!ended , "ended"); 
    ended = true; // پایان حراج
    if (highOrderAddress != address(0)) {  // اگر شخصی که بالاترین پیشنهاد را داده ادرس ان برابر صفر نبود
      nft.safeTransferFrom(address(this), highOrderAddress, nftId); //ان اف تی را به ان انتقال می دهیم
      seller.transfer(highOrder); //بالا ترین پیشنهاد 
    }else {
      nft.safeTransferFrom(address(this), seller, nftId); //اگر شخصی برنده نبود ان اف تی به خودمان برگردد
    }
    emit End(highOrderAddress , highOrder);
}
}