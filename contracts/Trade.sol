pragma solidity ^0.4.4;
contract Trade {
  uint256 public value;
  address public exporter;
  address public importer;

  enum State {Created, Locked, Inactive}

  State public state;

  function Trade(address _importer, uint256 _value) {
    exporter = msg.sender;
    importer = _importer;
    value = _value;
    //msg.value = _value;
    //value = msg.value / 2;
    //if(2 * value != msg.value) throw;
  }

  function getValue() returns (uint256) {
      return value;
  }
  function getMsgValue() returns (uint256) {
      return msg.value;
  }
  function getImporter() returns (address) {
    return importer;
  }

  function getImporterBalance() returns (uint) {
    return importer.balance;
  }

  function getExporterBalance() returns (uint) {
    return msg.sender.balance;
  }
  function getContractBalance() returns (uint) {
    return this.balance;
  }
  function setImporter(address _importer) public {
    importer = _importer;
  }
  function transfer(address _importer) payable public {
    this.transfer(value);
  }
  function() payable {
    throw;
  }
  modifier require(bool _condition) {
    if(!_condition) throw;
    _;
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

  event aborted();
  event tradeConfirmed();
  event goodReceived();

  function abort()
    onlyExporter
    inState(State.Created)
  {
    aborted();
    //exporter.sender(this.balance);
    importer.send(value);
    state = State.Inactive;
  }

  function confirmTrade()
    inState(State.Created)
    require(msg.value == value)
  {
    tradeConfirmed();
    importer = msg.sender;
    state = State.Locked;
  }

  function confirmReceived()
    onlyImporter
    inState(State.Locked)
  {
    goodReceived();
    //importer.send(value);
    exporter.send(value);
    //msg.sender.transfer(value);
    state = State.Inactive;
  }
}
