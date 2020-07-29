# Network Models simulation using NS-2 simulator
<!-- OL -->
1. Files present:
    <!-- UL -->
    * TCL Files (for modeling)
    * Awk scripts (for post-processing)
    * Shell scripts (for scripting)
    * Modified .cpp files

2. Simulation Modes:
    <!-- UL -->
    * Wireless 802.11 static network
    * Wireless 802.15.4 mobile network
    * Cross-network simulations between wired and static wireless mode
    * Satellite mode
    * LTE network mode
  
3. Parameters varied:
    <!-- OL -->

    1. For basic modes (802.11 and 802.15.4):
    
      | Parameter			  |      Values (varied)		  |
      |---------------------|:-----------------------------:|
      | No. of nodes		  |20, 40, 60, 80, 100|
      | Flow   |10, 20, 30, 40, 50|
      | Packet rate    |100, 200, 300, 400, 500|
      | Coverage area **(only for 802.11 static)**    |{1, 2, 3, 4, 5}.TX-Range|
      | Speed of nodes **(only for 802.15.4 mobile)**    |{5, 10, 15, 20, 25} m/s|


    2. For additional modes, these parameters were varied

      | Satellite			  |      LTE		  |
      |---------------------|:-----------------------------:|
      |Orbital inclination|Average Page Size|
      |Polar|AMR|
      |Link Bandwidth|Subscribers|
  
  
  

4. Metrics considered for measurement:
  <!-- UL -->

  * Network Throughput (Average and Instantaneous and Per-Node)
  * End-to-end Delay
  * Packet delivery and drop ratios
  * Energy consumption
  * Residual Energy per node
  * Link-Queue variation

5. Experimented with modified simulation scenarios: 
  <!-- UL -->

  * Congestion control mechanism
  * Queue size variation (random drop instead of drop-tail)
  * Modified RTT calculation mechanism
  * Modified MAC-Layer protocol
