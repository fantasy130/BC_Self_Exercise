pragma solidity ^0.4.4;

contract InternationalTrade {

    address exporter;
    address importer;
    uint256 price;
    State state;

    enum State {Created, Dealed, Exported, Passed, NotPassed, ConfirmNotPassed, Refunded, Closed}

    event Deal(uint256,address,address);
    event Received(uint256,address,address);
    event Refund(uint256,address,address);
    event Export(uint256,address,address);
    event Verify(uint256,address,address);
    event ConfirmVerify(uint256,address,address);

    constructor(address _exporter) public
    {
        exporter = _exporter;
        importer = msg.sender;
        state = State.Created;
    }
    modifier onlyImporter() {
        if(msg.sender != importer) throw;
        _;
    }
    modifier onlyExporter() {
        if(msg.sender != exporter) throw;
        _;
    }
    modifier inState(State _state) {
        if(state != _state) throw;
        _;
    }
    modifier isImporterBalanceEnough() {
        if(msg.sender.balance < msg.value) throw;
        _;
    }
    function getBalance() returns (uint) {
        return this.balance;//0
    }

    function confirmDeal() payable onlyImporter isImporterBalanceEnough inState(State.Created) returns(bool success){
        price = msg.value;
        Deal(price,exporter,importer);
        state = State.Dealed;
        return true;
    }

    function confirmExport() payable onlyExporter inState(State.Dealed) returns(bool success){
        Export(price,exporter,importer);
        state = State.Exported;
        return true;
    }

    function confirmReceived() payable onlyImporter inState(State.Passed) returns(bool success){
        Received(price,exporter,importer);
        state = State.Closed;
        return (exporter.send(this.balance));
    }

    function verifiedPassed() payable onlyImporter inState(State.Exported) returns(bool success){
        Verify(price,exporter,importer);
        state = State.Passed;
        return true;
    }

    function verifiedNotPassed() payable onlyImporter inState(State.Exported) returns(bool success){
        Verify(price,exporter,importer);
        state = State.NotPassed;
        return true;
    }

    function confirmVerifiedNotPassed() payable onlyExporter inState(State.NotPassed) returns(bool success){
        Received(price,exporter,importer);
        state = State.ConfirmNotPassed;
        return true;
    }

    function refund() payable onlyImporter inState(State.ConfirmNotPassed) returns(bool success){
        Refund(price,exporter,importer);
        state = State.Refunded;
        return (importer.send(price));
    }

    function autoClose() payable inState(State.Exported) returns(bool success){
        //ToDo: Send eth to exporter automatically if the importer dosn't confirm receveing the goods.
    }
    function autoRefund() payable inState(State.Dealed) returns(bool success){
        //ToDo: Refund  automatically if the exporter dosn't send goods to importer.
    }
    function () payable {

    }
}
