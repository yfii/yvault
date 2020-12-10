contract StrategyFortube {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public output = address(0x658A109C5900BC6d2357c87549B651670E5b0539); //for
    address  public unirouter = address(0x039B5818e51dfEC86c1D56A4668787AF0Ed1c068); // unisave 
    address constant public weth = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c); // used for for <> weth <> usdc route

    address constant public yfii = address(0x7F70642d88cf1C4a3a7abb072B53B929b653edA5);


    address constant public fortube = address(0x0cEA0832e9cdBb5D476040D58Ea07ecfbeBB7672);//主合约.
    address  public fortube_reward = address(0x55838F18e79cFd3EA22Eea08Bd3Ec18d67f314ed); //领取奖励的合约
    
    address  public want; 

    
    uint public strategyfee = 100;
    uint public fee = 300;
    uint public burnfee = 500;
    uint public callfee = 100;
    uint constant public max = 1000;

    uint public withdrawalFee = 0;
    uint constant public withdrawalMax = 10000;
    
    address public governance;
    address public strategyDev;
    address public controller;
    address public burnAddress = 0xB6af2DabCEBC7d30E440714A33E5BD45CEEd103a;

    string public getName;

    address[] public swap2YFIIRouting;
    address[] public swap2TokenRouting;
    
    
    constructor(address _want) public {
        want = _want;
        governance = tx.origin;
        controller = 0x5B916D02A9745C64EC6C0AFe41Ee4893Dd5a01B7;
        getName = string(
            abi.encodePacked("yfii:Strategy:", 
                abi.encodePacked(IERC20(want).name(),"The Force Token"
                )
            ));
        swap2YFIIRouting = [output,weth,yfii];
        swap2TokenRouting = [output,weth,want];
        doApprove();
        strategyDev = tx.origin;
    }

    function doApprove () public{
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, uint(-1));
    }

    function setFortubeReward(address _reward) public {
        require(msg.sender == governance, "!governance");
        fortube_reward = _reward;
    }    
    function setUnirouter(address _unirouter) public {
        require(msg.sender == governance, "!governance");
        unirouter = _unirouter;
    }
    
    
    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        address _controller = For(fortube).controller();
        if (_want > 0) {
            IERC20(want).safeApprove(_controller, 0);
            IERC20(want).safeApprove(_controller, _want);
            For(fortube).deposit(want,_want);
        }
        
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        address _controller = For(fortube).controller();
        require(IBankController(_controller).getFTokeAddress(want) != address(_asset),"fToken");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        
        uint _fee = 0;
        if (withdrawalFee>0){
            _fee = _amount.mul(withdrawalFee).div(withdrawalMax);        
            IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
        }
        
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance,"!governance");
        _withdrawAll();
        
        
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        uint b = fToken.balanceOf(address(this));
        For(fortube).withdraw(want,b);
    }
    
    function harvest() public {
        require(!Address.isContract(msg.sender),"!contract");
        ForReward(fortube_reward).claimReward();
        doswap();
        dosplit();//分yfii
        deposit();
    }

    function doswap() internal {
        uint256 _2token = IERC20(output).balanceOf(address(this)); //100%
        // uint256 _2yfii = IERC20(output).balanceOf(address(this)).mul(10).div(100);  //10%
        UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
        // UniswapRouter(unirouter).swapExactTokensForTokens(_2yfii, 0, swap2YFIIRouting, address(this), now.add(1800));
    }
    function dosplit() internal{
        uint b = IERC20(want).balanceOf(address(this)).mul(10).div(100);//10% want
        uint _fee = b.mul(fee).div(max);
        uint _callfee = b.mul(callfee).div(max);
        uint _burnfee = b.mul(burnfee).div(max);
        IERC20(want).safeTransfer(Controller(controller).rewards(), _fee); //3%  3% team 
        IERC20(want).safeTransfer(msg.sender, _callfee); //call fee 1%
        IERC20(want).safeTransfer(burnAddress, _burnfee); //burn fee 5%

        if (strategyfee >0){
            uint _strategyfee = b.mul(strategyfee).div(max); //1%
            IERC20(want).safeTransfer(strategyDev, _strategyfee);
        }
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        For(fortube).withdrawUnderlying(want,_amount);
        return _amount;
    }
    
    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }
    
    function balanceOfPool() public view returns (uint) {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        return fToken.calcBalanceOfUnderlying(address(this));
    }
    
    
    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }
    function setFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        fee = _fee;
    }
    function setStrategyFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        strategyfee = _fee;
    }
    function setCallFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        callfee = _fee;
    }
    function setBurnFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        burnfee = _fee;
    }
    function setBurnAddress(address _burnAddress) public{
        require(msg.sender == governance, "!governance");
        burnAddress = _burnAddress;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        require(_withdrawalFee <=100,"fee >= 1%"); //max:1%
        withdrawalFee = _withdrawalFee;
    }
}
