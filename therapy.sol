pragma solidity >=0.4.22 <0.7.0;

contract TherapySchedule {
    
    //  === Authorisation and Worker info storage ===
    
    // Owner address, in this case, Manuela's
    //address immutable private boss;
    address immutable private boss;
    
    // Possible status for workers.
    // Workers are never deleted from the system when fired. Instead, status changes in order to revoke permissions.
    // default == nan
    // hired == active
    // fired == terminated
    enum WorkerStatus { nan, active, terminated }
    
    // Worker information structure.
    // index - index for worker in worker index
    // name - worker name
    // addr - worker address
    struct Worker {
        uint id;
        string name;
        WorkerStatus status;
        address addr;
    }
    
    // List of worker addresses with permission to add activities.
    // This works as an index where the position in the array
    // is equivalent to Worker.id - 1 .
    address[] public workerIndex;
    
    // Storage of worker information mapped to their address.
    mapping(address => Worker) public workerStorage;
    
    
    // ===============================================
    
    
    //  === Activity data structure and storage ===
    
    // Possible types of activities
    enum ActivityType { ultrasound, current, aerosol }
    
    // Ultrasound properties.
    // id - activity id
    // pot - potency
    // freq - frequency
    struct UltraSound {
        uint id;
        uint pot;
        uint freq;
    }
    
    // Current properties.
    // id - activity id
    // diam - diameter
    // hum - humidity
    struct Current {
        uint id;
        uint diam;
        uint hum;
    }
    
    // Aerosol properties.
    // id - activity id
    // vent - ventilan level
    struct Aerosol {
        uint id;
        uint vent;
    }
    
    // Activity instance structure.
    // id - activity id
    // s_date - start date
    // e_date - end date
    // descr - description
    // worker - worker id
    // act - activity type
    struct ActivityInst {
        uint id;
        string s_date;
        string e_date;
        string descr;
        uint worker;
        ActivityType act;
    }
    
    // List of all recorded activities, with reference to the activity type.
    // This works as an index where the position in the array
    // is equivalent to ActivityInst.id - 1 and {Ultrasound,Current,Aerosol}.id - 1 .
    ActivityType[] public activityIndex;
    
    // Storage of Activity instances recorded as well as
    // specific information for each type of activity.
    // Information is mapped to an integer corresponding to the activity id.
    mapping(uint => ActivityInst) public activityStorage;
    mapping(uint => UltraSound) public ultraSoundStorage;
    mapping(uint => Current) public currentStorage;
    mapping(uint => Aerosol) public aerosolStorage;
    
    //  =====================================================
    
    
    constructor ( address _addr ) public {
        boss = _addr;
    }
    
    // Add worker to storage, if it does not exist
    // add the worker address to the index and 
    // use the index position as the id
    // if successful, returns the worker id
    function addWorker( string memory _name, address _addr ) public returns ( uint workerId ){
        require(msg.sender == boss, "No permission to add workers");
        
        if(workerStorage[_addr].id > 0){
            // worker already exists
            revert("Worker with this address already exists");
        }
        else {
            // worker does not exist.
            workerIndex.push(_addr);
            uint id = workerIndex.length;
            
            workerStorage[_addr].id = id;
            workerStorage[_addr].name = _name;
            workerStorage[_addr].addr = _addr;
            workerStorage[_addr].status = WorkerStatus.active;
            
            return id;
        }
    }
    
    
    // Change worker status to terminated, if it exists
    // _addr - address of worker to terminate
    // if successful, returns true
    function fireWorker( address _addr ) public returns ( bool done ){
        require(msg.sender == boss, "No permission to remove workers");
        
        if(workerStorage[_addr].id == 0){
            // worker does not exist
            revert("Worker with this address does not exist");
        }
        else{
            workerStorage[_addr].status = WorkerStatus.terminated;
            return true;
        }
    }
    
    // Add new activity
    // _s_date - start date
    // _e_date - end date
    // _descr - description
    // _type - activity type {0 - ultrasound, 1 - current, 2 - aerosol }
    // _properties - array of activity properties
    // if successful, returns true
    function addActivity ( string memory _s_date, string memory _e_date, string memory _descr, uint _type, uint[] memory _properties ) public returns ( uint activityId ){
        if(workerStorage[msg.sender].status != WorkerStatus.active ){
            // Account address does not correspond to an active worker
            revert("Worker cannot create an activity");
        }
        else{
            // Find the activity type by the activity type id,
            // add a new entry to the index,
            // get the id from the new length of the index,
            // and get the worker id from the sender address.
            ActivityType t = ActivityType(_type);
            activityIndex.push( t );
            uint id = activityIndex.length;
            uint workerId = workerStorage[msg.sender].id;
            
            activityStorage[id].id = id;
            activityStorage[id].s_date = _s_date;
            activityStorage[id].e_date = _e_date;
            activityStorage[id].descr = _descr;
            activityStorage[id].worker = workerId;
            activityStorage[id].act = t;
            
            // Check the activity type and add the proper struct
            // to storage.
            if( t == ActivityType.ultrasound) {
                require(_properties.length == 2, "Exactly two paramenters should be supplied for Ultrasound therapy [potency, frequency]");
                ultraSoundStorage[id].id = id;
                ultraSoundStorage[id].pot = _properties[0];
                ultraSoundStorage[id].freq = _properties[1];
                return id;
            }
            if( t == ActivityType.current) {
                require(_properties.length == 2, "Exactly two paramenters should be supplied for Current therapy [diameter, humidity]");
                currentStorage[id].id = id;
                currentStorage[id].diam = _properties[0];
                currentStorage[id].hum = _properties[1];
                return id;
            }
            if( t == ActivityType.aerosol) {
                require(_properties.length == 1, "Exactly one paramenter should be supplied for Aerosol therapy [ventilan]");
                aerosolStorage[id].id = id;
                aerosolStorage[id].vent = _properties[0];
                return id;
            }
        }
    }
}

// BONUS - creating multiple clinic schedules
// TODO - this could be improved by adding the rest of the CRUD methods for managing clinics like changing the owner or "boss" and deleting existing clinics.
contract Clinics{
    
    // Default clinic structure
    // id - clinic id
    // addr - clinic smart contract address
    // boss - address of the clinic owner
    // name - clinic name
    // clinic - the smart contract instance 
    struct Clinic {
        uint id;
        address addr;
        address boss;
        string name;
        TherapySchedule clinic;
    }
    
    // List of all clinic smart contract addresses created
    address[] public clinicIndex;
    
    // Map of all clinic structures to the corresponding address
    mapping(address => Clinic) public clinicStorage;
    
    // Creation of the exercise default contract on contract deployment
    constructor () public {
        newClinic("Manuela", 0xE678830971Da57Ec0E7E6E747998527E76251F6e);
    }
    
    // New clinic smart contract generation and addition to the Clinics contract storage
    // _name - clinic name
    // _boss - address of owner
    // returns the deployed contract address
    function newClinic( string memory _name, address _boss) public returns ( address clinicAddress){
        
        TherapySchedule newTherapy = new TherapySchedule(_boss);
        address clinic_address = address (newTherapy);
        clinicIndex.push(clinic_address);
        uint id = clinicIndex.length;
            
        clinicStorage[clinic_address].clinic = newTherapy;
        clinicStorage[clinic_address].addr = clinic_address;
        clinicStorage[clinic_address].boss = _boss;
        clinicStorage[clinic_address].name = _name;
        clinicStorage[clinic_address].id = id;
        
        return clinic_address;
    }

    // Wrapper around the addWorker method in TherapySchedule
    // Notably, there is the addition of _contract_addr - the address for the desired clinic smart contract
    function addWorker(address _contract_addr, string memory _name, address _addr ) public returns ( uint workerId ){
        if(clinicStorage[_contract_addr].id == 0){
            revert("Clinic with this address does not exist");
        }
        
        return clinicStorage[_contract_addr].clinic.addWorker(_name, _addr);
    }
    
    // Wrapper around the fireWorker method in TherapySchedule
    // Notably, there is the addition of _contract_addr - the address for the desired clinic smart contract
    function fireWorker(address _contract_addr, address _addr ) public returns ( bool done ){
        if(clinicStorage[_contract_addr].id == 0){
            revert("Clinic with this address does not exist");
        }
        
        return clinicStorage[_contract_addr].clinic.fireWorker( _addr );
    }
    
    // Wrapper around the addActivity method in TherapySchedule
    // Notably, there is the addition of _contract_addr - the address for the desired clinic smart contract
    function addActivity (address _contract_addr, string memory _s_date, string memory _e_date, string memory _descr, uint _type, uint[] memory _properties ) public returns ( uint activityId ){
        if(clinicStorage[_contract_addr].id == 0){
            revert("Clinic with this address does not exist");
        }
        
        return clinicStorage[_contract_addr].clinic.addActivity(_s_date, _e_date, _descr, _type,_properties);

    }
}