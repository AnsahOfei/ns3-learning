#include "wsn_shared.h"
#include <fstream>
#include <iomanip>

NS_LOG_COMPONENT_DEFINE("WsnClusteringExperiment");

// --- Protocol-Specific Applications ---

class LEACHApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::LEACHApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    void ExecuteRound() override {
        double p = 0.05;
        Ptr<UniformRandomVariable> rand = CreateObject<UniformRandomVariable>();
        if (rand->GetValue(0,1) < p) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &LEACHApp::ExecuteRound, this);
    }
};

class HEEDApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::HEEDApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    void ExecuteRound() override {
        double eRat = m_energy->GetRemainingEnergy() / m_energy->GetInitialEnergy();
        if (eRat > 0.5) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &HEEDApp::ExecuteRound, this);
    }
};

class SEPApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::SEPApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    bool m_isAdvanced = false;
    void ExecuteRound() override {
        double p = m_isAdvanced ? 0.1 : 0.02;
        Ptr<UniformRandomVariable> rand = CreateObject<UniformRandomVariable>();
        if (rand->GetValue(0,1) < p) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &SEPApp::ExecuteRound, this);
    }
};

class DEECApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::DEECApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    void ExecuteRound() override {
        double p = 0.05 * (m_energy->GetRemainingEnergy() / 100.0);
        Ptr<UniformRandomVariable> rand = CreateObject<UniformRandomVariable>();
        if (rand->GetValue(0,1) < p) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &DEECApp::ExecuteRound, this);
    }
};

class IFUCApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::IFUCApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    void ExecuteRound() override {
        double score = (m_energy->GetRemainingEnergy() / 100.0) + (1.0 / (m_id + 1.0));
        if (score > 1.0) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &IFUCApp::ExecuteRound, this);
    }
};

class APSOApp : public ClusteringApp {
public:
    static TypeId GetTypeId(void) {
        static TypeId tid = TypeId("ns3::APSOApp").SetParent<ClusteringApp>().SetGroupName("Applications");
        return tid;
    }
    void ExecuteRound() override {
        if (m_energy->GetRemainingEnergy() > 80.0) { SendPacket(500, true); } else { SendPacket(50, false); }
        Simulator::Schedule(Seconds(10.0), &APSOApp::ExecuteRound, this);
    }
};

// --- Main Experiment ---

int main(int argc, char *argv[]) {
    std::string protoType = "leach"; 
    std::string topoType = "grid"; 
    std::string mode = "standard";
    uint32_t nNodes = 20;
    double simTime = 1800.0; // Phase 6: Extended 30-minute window
    bool heterogeneous = false; // Phase 6: Batch H heterogeneous energy
    double fieldSize = 150.0; // Phase 6: Expandable to 200m for Batch H
    uint32_t seed = 1;
    std::string csvOut = "";

    CommandLine cmd(__FILE__);
    cmd.AddValue("proto", "leach, heed, sep, deec, ifuc, apso", protoType);
    cmd.AddValue("topo", "grid, star, mesh", topoType);
    cmd.AddValue("mode", "standard, duty-cycle, proto, proto-duty", mode);
    cmd.AddValue("nodes", "Number of nodes", nNodes);
    cmd.AddValue("time", "Simulation time in seconds", simTime);
    cmd.AddValue("heterogeneous", "Use distance-based energy tiers (Batch H)", heterogeneous);
    cmd.AddValue("field", "Field size in meters", fieldSize);
    cmd.AddValue("seed", "RNG seed (for reproducibility)", seed);
    cmd.AddValue("csvOut", "Path to CSV summary output (optional)", csvOut);
    cmd.Parse(argc, argv);

    // Set RNG seed early for reproducibility
    RngSeedManager::SetSeed(seed);

    TopologyType topo = (topoType == "star") ? STAR : ((topoType == "mesh") ? MESH : GRID);
    bool useDuty = (mode == "duty-cycle" || mode == "proto-duty");
    bool useProto = (mode == "proto" || mode == "proto-duty");

    NodeContainer sink, sensors;
    sink.Create(1); sensors.Create(nNodes);
    NodeContainer all; all.Add(sink); all.Add(sensors);

    std::cout << "Starting Topology Setup (Field: " << fieldSize << "m)..." << std::endl;
    SetupTopology(all, topo, nNodes, fieldSize); // Pass field size
    
    std::cout << "Starting LrWpan Setup..." << std::endl;
    LrWpanHelper lrWpanHelper;
    Ptr<SingleModelSpectrumChannel> channel = CreateObject<SingleModelSpectrumChannel>();
    Ptr<LogDistancePropagationLossModel> lossModel = CreateObject<LogDistancePropagationLossModel>();
    channel->AddPropagationLossModel(lossModel);
    Ptr<ConstantSpeedPropagationDelayModel> delayModel = CreateObject<ConstantSpeedPropagationDelayModel>();
    channel->SetPropagationDelayModel(delayModel);
    lrWpanHelper.SetChannel(channel);
    NetDeviceContainer devices = lrWpanHelper.Install(all);

    for (uint32_t i = 0; i < devices.GetN(); ++i) {
        Ptr<LrWpanNetDevice> dev = DynamicCast<LrWpanNetDevice>(devices.Get(i));
        dev->GetMac()->SetShortAddress(Mac16Address(i + 1));
        dev->GetMac()->SetExtendedAddress(Mac64Address(i + 1));
    }

    std::cout << "Starting Network Setup..." << std::endl;
    InternetStackHelper internet; internet.Install(all);
    SixLowPanHelper sixlowpan; NetDeviceContainer sixDevices = sixlowpan.Install(devices);
    Ipv6AddressHelper ipv6; ipv6.SetBase(Ipv6Address("2001:db8::"), Ipv6Prefix(64));
    Ipv6InterfaceContainer interfaces = ipv6.Assign(sixDevices);

    // Phase 6: Heterogeneous Energy Allocation (Batch H)
    EnergySourceContainer sources;
    if (heterogeneous) {
        std::cout << "Using HETEROGENEOUS energy allocation (Batch H)" << std::endl;
        Ptr<MobilityModel> sinkMobility = all.Get(0)->GetObject<MobilityModel>();
        Vector sinkPos = sinkMobility->GetPosition();
        
        for (uint32_t i = 0; i < all.GetN(); ++i) {
            Ptr<MobilityModel> nodeMobility = all.Get(i)->GetObject<MobilityModel>();
            Vector nodePos = nodeMobility->GetPosition();
            double distance = CalculateDistance(sinkPos, nodePos);
            
            double initialEnergy = 2100.0; // Default Tier 2
            if (distance < 65.0) {
                initialEnergy = 1500.0; // Tier 1: Sink-adjacent
            } else if (distance >= 135.0) {
                initialEnergy = 3000.0; // Tier 3: Periphery
            }
            
            BasicEnergySourceHelper basicHelper;
            basicHelper.Set("BasicEnergySourceInitialEnergyJ", DoubleValue(initialEnergy));
            EnergySourceContainer nodeSrc = basicHelper.Install(all.Get(i));
            sources.Add(nodeSrc.Get(0));
            
            std::cout << "Node " << i << ": dist=" << distance << "m, energy=" << initialEnergy << "J" << std::endl;
        }
    } else {
        std::cout << "Using HOMOGENEOUS energy allocation (2100J per node)" << std::endl;
        BasicEnergySourceHelper basicHelper;
        basicHelper.Set("BasicEnergySourceInitialEnergyJ", DoubleValue(2100.0)); // Phase 6: Updated from 100J
        sources = basicHelper.Install(all);
    }

    // Robust Address Retrieval
    Ipv6Address sinkAddr;
    Ptr<Ipv6> ipv6Sink = all.Get(0)->GetObject<Ipv6>();
    if (ipv6Sink->GetNAddresses(1) > 0) {
        sinkAddr = ipv6Sink->GetAddress(1, ipv6Sink->GetNAddresses(1)-1).GetAddress();
    } else {
        sinkAddr = interfaces.GetAddress(0, 0); // Fallback
    }

    std::vector<Ptr<LrWpanNetDevice>> sensorDevs;
    g_aliveNodesCount = all.GetN();
    for (uint32_t i = 0; i < devices.GetN(); ++i) {
        g_nodeAliveStatus[i] = true;
        Ptr<LrWpanNetDevice> dev = DynamicCast<LrWpanNetDevice>(devices.Get(i));
        Ptr<SimpleDeviceEnergyModel> sem = CreateObject<SimpleDeviceEnergyModel>();
        sem->SetEnergySource(DynamicCast<BasicEnergySource>(sources.Get(i)));
        sem->SetCurrentA(RX_CURRENT);
        sources.Get(i)->AppendDeviceEnergyModel(sem);
        dev->GetPhy()->TraceConnectWithoutContext("TrxState", MakeBoundCallback(&PhyStateChangeCallback, sem));
        sources.Get(i)->TraceConnectWithoutContext("RemainingEnergy", MakeBoundCallback(&RemainingEnergyTrace, i));
        g_nodeEnergyModels[i] = sem; // Register for hard cut-off
        if (i > 0) sensorDevs.push_back(dev);
    }

    if (useProto) {
        for (uint32_t i = 0; i < sensors.GetN(); ++i) {
            Ptr<ClusteringApp> app;
            if (protoType == "leach") app = CreateObject<LEACHApp>();
            else if (protoType == "heed") app = CreateObject<HEEDApp>();
            else if (protoType == "sep") app = CreateObject<SEPApp>();
            else if (protoType == "deec") app = CreateObject<DEECApp>();
            else if (protoType == "ifuc") app = CreateObject<IFUCApp>();
            else app = CreateObject<APSOApp>();
            
            app->Setup(sinkAddr, i + 1, DynamicCast<BasicEnergySource>(sources.Get(i + 1)));
            sensors.Get(i)->AddApplication(app);
            app->SetStartTime(Seconds(1.1 + (i*0.01))); app->SetStopTime(Seconds(simTime));
        }
    } else {
        UdpServerHelper server(9); server.Install(sink);
        UdpClientHelper client(sinkAddr, 9);
        client.SetAttribute("Interval", TimeValue(Seconds(5.0)));
        ApplicationContainer apps = client.Install(sensors);
        for (uint32_t i=0; i<apps.GetN(); ++i) {
            apps.Get(i)->SetStartTime(Seconds(2.0 + (i*0.1))); // Staggered start
            apps.Get(i)->SetStopTime(Seconds(simTime));
        }
    }

    if (useDuty) {
        Ptr<UniformRandomVariable> rand = CreateObject<UniformRandomVariable>();
        for (double t = 2.0; t < simTime; t += 10.0) {
            for (auto dev : sensorDevs) {
                double jitter = rand->GetValue(0, 0.5); // 500ms jitter
                Simulator::Schedule(Seconds(t + jitter), &SetPhyState, dev, true);
                Simulator::Schedule(Seconds(t + jitter + 1.0), &SetPhyState, dev, false);
            }
        }
    }

    // Phase 6: NetAnim DISABLED to save memory and disk space
    // AnimationInterface anim("cluster_" + protoType + "_" + topoType + "_" + mode + ".xml");
    // anim.UpdateNodeDescription(sink.Get(0), "SINK");
    // anim.UpdateNodeColor(sink.Get(0), 255, 0, 0);

    FlowMonitorHelper flowmon; Ptr<FlowMonitor> monitor = flowmon.InstallAll();
    Simulator::Stop(Seconds(simTime));
    Simulator::Run();

    monitor->CheckForLostPackets();
    double totalStartingEnergy = 0;
    double totalRemainingEnergy = 0;
    uint32_t aliveNodes = 0;
    for (uint32_t i = 0; i < sources.GetN(); ++i) {
        double starting = sources.Get(i)->GetInitialEnergy();
        double remaining = std::max(0.0, sources.Get(i)->GetRemainingEnergy());
        totalStartingEnergy += starting;
        totalRemainingEnergy += remaining;
        if (remaining > 0) aliveNodes++;
    }
    double totalEnergyConsumed = totalStartingEnergy - totalRemainingEnergy;

    FlowMonitor::FlowStatsContainer stats = monitor->GetFlowStats();
    uint64_t tx = 0, rx = 0, rxBytes = 0, txBytes = 0; double delay = 0, jitter = 0;
    for (auto& f : stats) { 
        tx += f.second.txPackets; 
        rx += f.second.rxPackets; 
        rxBytes += f.second.rxBytes;
        txBytes += f.second.txBytes;
        delay += f.second.delaySum.GetSeconds(); 
        jitter += f.second.jitterSum.GetSeconds();
    }
    
    double pdr = (tx > 0 ? (100.0 * rx / tx) : 0);
    double throughput = (rxBytes * 8.0) / simTime;
    double bandwidth = (txBytes * 8.0) / simTime; // Total offered load
    double avgJitter = (rx > 1) ? (jitter / (rx - 1)) : 0;
    double efficiency = (rxBytes > 0) ? (totalEnergyConsumed / (rxBytes * 8.0)) : 0;
    double responseTime = (rx > 0 ? (delay / rx * 1000.0) : 0); // end-to-end in ms
    double ber = (tx > 0 && rx > 0) ? (1.0 - std::pow((double)rx/tx, 1.0/800.0)) : (tx > 0 ? 1.0 : 0); // Estimate for 100-byte packets
    
    std::cout << "\nRESULT|PROTO:" << protoType << "|TOPO:" << topoType << "|MODE:" << mode 
              << "|START_ENERGY:" << totalStartingEnergy << "|REM_ENERGY:" << totalRemainingEnergy 
              << "|ENERGY_CONS:" << totalEnergyConsumed << "|ALIVE_NODES:" << aliveNodes
              << "|PDR:" << pdr << "|LATENCY:" << (rx > 0 ? (delay/rx) : 0)
              << "|THROUGHPUT:" << throughput << "|JITTER:" << avgJitter 
              << "|EFFICIENCY:" << efficiency 
              << "|BER:" << ber << "|BANDWIDTH:" << bandwidth 
              << "|RESPONSETIME:" << responseTime << std::endl;

    // Optional CSV output for automated analysis (Checkpoint A)
    if (!csvOut.empty()) {
        std::ofstream csv(csvOut);
        if (csv.is_open()) {
            csv << "proto,topo,mode,nodes,simTime,startEnergy,remainingEnergy,energyConsumed,aliveNodes,tx,rx,txBytes,rxBytes,pdr,latency,throughput,jitter,efficiency,ber,bandwidth,responseTime" << std::endl;
            csv << protoType << "," << topoType << "," << mode << "," << nNodes << "," << simTime << ",";
            csv << std::fixed << std::setprecision(6) << totalStartingEnergy << "," << totalRemainingEnergy << "," << totalEnergyConsumed << "," << aliveNodes << ",";
            csv << tx << "," << rx << "," << txBytes << "," << rxBytes << ",";
            csv << std::fixed << std::setprecision(4) << pdr << "," << (rx > 0 ? (delay/rx) : 0) << "," << throughput << "," << avgJitter << "," << efficiency << "," << ber << "," << bandwidth << "," << responseTime << std::endl;
            csv.close();
        } else {
            std::cerr << "Warning: could not open CSV output file: " << csvOut << std::endl;
        }

        // Per-node energy dump
        std::string pernode = csvOut + std::string(".pernode.csv");
        std::ofstream pcsv(pernode);
        if (pcsv.is_open()) {
            pcsv << "nodeId,role,initialEnergyJ,remainingEnergyJ,consumedEnergyJ" << std::endl;
            for (uint32_t i = 0; i < sources.GetN(); ++i) {
                double ini = sources.Get(i)->GetInitialEnergy();
                double rem = std::max(0.0, sources.Get(i)->GetRemainingEnergy());
                double cons = ini - rem;
                std::string role = (i == 0) ? "sink" : "sensor";
                pcsv << i << "," << role << "," << std::fixed << std::setprecision(6) << ini << "," << rem << "," << cons << std::endl;
            }
            pcsv.close();
        } else {
            std::cerr << "Warning: could not open per-node CSV output file: " << pernode << std::endl;
        }
    }

    Simulator::Destroy();
    return 0;
}
