
import "IColonyFactory.sol";
import "IUpgradable.sol";
import "Colony.sol";

contract ColonyFactory is IColonyFactory {

  event ColonyCreated(bytes32 colonyKey, address colonyAddress, address colonyOwner, uint now);
  event ColonyDeleted(bytes32 colonyKey, address colonyOwner, uint now);
  event ColonyUpgraded(address colonyAddress, address colonyOwner, uint now);

  struct ColonyRecord {
    uint index;
    bool _exists;
  }

  struct ColonyMapping {
    mapping(bytes32 => ColonyRecord) catalog;
    address [] data;
  }

  ColonyMapping colonies;

  function ColonyFactory()
  refundEtherSentByAccident
  {

  }

  /// @notice this function registers the address of the RootColonyResolver
  /// @param rootColonyResolverAddress_ the default root colony resolver address
  function registerRootColonyResolver(address rootColonyResolverAddress_)
  refundEtherSentByAccident
  onlyOwner
  {
    rootColonyResolverAddress = rootColonyResolverAddress_;
  }

  /// @notice creates a Colony
  function createColony(bytes32 key_, address shareLedger_, address taskDB_)
  {
    var colonyIndex = colonies.data.length++;
    var colony = new Colony(rootColonyResolverAddress, shareLedger_, taskDB_);

    Ownable(taskDB_).changeOwner(colony);
    Ownable(shareLedger_).changeOwner(colony);

    colonies.catalog[key_] = ColonyRecord({index: colonyIndex, _exists: true});
    colonies.data[colonyIndex] = colony;

    ColonyCreated(key_, colony, tx.origin, now);
  }

  function removeColony(bytes32 key_)
  refundEtherSentByAccident
  {
    colonies.catalog[key_]._exists = false;
    ColonyDeleted(key_, tx.origin, now);
  }

  function getColony(bytes32 key_) constant returns(address)
  {
    var colonyIndex = colonies.catalog[key_].index;
    return colonies.data[colonyIndex];
  }

  function getColonyAt(uint256 idx_) constant returns(address)
  {
    return colonies.data[idx_];
  }

  function upgradeColony(bytes32 key_)
  {
    uint256 colonyIndex = colonies.catalog[key_].index;
    address colonyAddress = colonies.data[colonyIndex];
    address taskDb = Colony(colonyAddress).taskDB();
    address shareLedger = Colony(colonyAddress).shareLedger();

    Colony colonyNew = new Colony(rootColonyResolverAddress, shareLedger, taskDb);
    IUpgradable(colonyAddress).upgrade(colonyNew);

    colonies.data[colonyIndex] = colonyNew;
    ColonyUpgraded(colonyNew, tx.origin, now);
  }

	function () {
		// This function gets executed if a
		// transaction with invalid data is sent to
		// the contract or just ether without data.
		// We revert the send so that no-one
		// accidentally loses money when using the
		// contract.
		throw;
	}
}
