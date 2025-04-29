# AAE6102_Assignment2

# Task 1 – Differential GNSS Positioning

### **1. Differential GNSS (DGNSS)**
DGNSS improves accuracy by using a reference station to calculate and broadcast corrections to users.
#### **Pros**
- **Improved Accuracy**: Achieves sub-meter precision, better than standalone GNSS.
- **Low Complexity**: Requires a single reference station, making it simpler than RTK or PPP.
- **Wide Coverage**: Effective for regional corrections.
#### **Cons**
- **Limited Precision**: Insufficient for centimeter-level requirements.
- **Dependency on Reference Stations**: Requires dense station networks.
- **Communication Burden**: Needs a continuous data link.

### **2. Real-Time Kinematic (RTK)**
RTK resolves carrier-phase ambiguities with corrections from a nearby reference station, achieving centimeter-level accuracy.
#### **Pros**
- **High Precision**: Provides real-time centimeter accuracy, ideal for precise applications like autonomous driving.  
- **Proven Reliability**: Widely used in various fields.
#### **Cons**
- **Short Baseline Limitation**: Effective only near reference stations (within 10–20 km).  
- **High Communication Overhead**: Requires stable data links.
- **Lack of Flexibility**: Limited by the availability of nearby reference stations.  

### **3. Precise Point Positioning (PPP)**
PPP uses precise satellite corrections and a single receiver, eliminating the need for nearby reference stations.
#### **Pros**
- **Global Coverage**: Operates anywhere with GNSS signals.  
- **Independence**: Does not rely on reference stations, maintaining accuracy over long distances.  
- **Privacy**: User coordinates are not shared with servers, unlike RTK.  
#### **Cons**
- **Long Convergence Times**: Requires 15–30 minutes for high precision.  
- **Moderate Accuracy for Smartphones**: Limited to decimeter or sub-meter levels due to noisy observations.  
- **Urban Challenges**: Performance degrades in urban canyons or dense forests.  

### **4. PPP-RTK**
PPP-RTK combines PPP and RTK to deliver fast, high-precision positioning using corrections from a reference network.
#### **Pros**
- **Centimeter-Level Accuracy**: Matches RTK's precision while maintaining PPP’s global coverage.  
- **Fast Convergence**: Achieves rapid initialization compared to PPP.  
- **Low Communication Burden**: Uses SSR corrections, reducing data transfer requirements.  
- **Scalability**: Supports many users simultaneously.  
- **Robustness**: Corrects GNSS-related errors like ionospheric and tropospheric delays.  
#### **Cons**
- **Infrastructure Complexity**: Requires a dense network of reference stations.  
- **Dependent on Data Quality**: Smartphone data quality and hardware constraints limit performance.  
- **Algorithm Complexity**: Demands advanced processing, challenging for low-cost devices.  

### **Smartphone Navigation: Challenges and Opportunities**
Since 2016, Android devices provide raw GNSS data, enabling advanced techniques like PPP and RTK on smartphones. 

#### **Key Challenges**
1. **Hardware Limitations**:  
   - Smartphones use low-cost, omnidirectional, linear-polarized antennas prone to multipath and signal degradation.  
   - High noise levels in carrier-phase observations limit precision.  
2. **Limited Satellite Signals**:  
   - Few L5/E5a satellites are tracked, reducing dual-frequency performance.  

#### **Opportunities**
- **PPP-RTK Potential**:  
   - PPP-RTK enables centimeter-level accuracy on smartphones, potentially transforming applications like location-based services (LBS) and crowdsourced mapping.  

### **Conclusion**
Each GNSS technique—DGNSS, RTK, PPP, and PPP-RTK—has its strengths and limitations. For smartphones, PPP-RTK is the most promising, offering centimeter-level accuracy with global coverage and reduced communication burdens. However, challenges such as hardware limitations, observation noise, and algorithmic complexity must be addressed. With ongoing advancements, PPP-RTK could unlock high-precision navigation for smartphones, enabling transformative applications in navigation, mapping, and autonomous systems.

---

### **References**
1. Cheng S, Wang F, Li G, et al. Single-frequency multi-GNSS PPP-RTK for smartphone rapid centimeter-level positioning [J]. *IEEE Sensors Journal*, 2023, 23(18): 21553-21561.  
2. Li X, Huang J, Li X, et al. Review of PPP–RTK: Achievements, challenges, and opportunities [J]. *Satellite Navigation*, 2022, 3(1): 28.




## **Task 2: Tracking**

### **Objective**
Adapt the tracking loop (DLL) to generate correlation plots and analyze tracking performance. Discuss the impact of urban interference on correlation peaks.

### **1. Open-sky**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/2-open1.png)  
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/open-ACF.png)  
- 

### **2. Urban**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/2-urban.png) 
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/urban-ACF.png)  


### **Results**
- In an open environment, the signal frequency domain is concentrated, the time domain signal is balanced, and the multi-correlator results show that the PRN signal peak is clear and the correlation is good.
- In an urban environment, the signal is interfered by the multipath effect, the noise is strong, the time domain signal fluctuates significantly, the multi-correlator result peak is low, and the signal correlation decreases.



## **Task 3: Navigation Data Decoding**

### **Objective**
Decode the navigation message and extract key parameters, such as ephemeris data, for at least one satellite.

### **Results**
Below is the navigation data message decoded from incoming signal of urban.
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/URBAN-PRN3.png) 
Below are the key parameters from urban message.
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/3-URBAN.png)  



# Task 4 – LEO Satellites for Navigation

## Challenges of Using LEO Satellites for GNSS Navigation
Low Earth Orbit (LEO) satellites, primarily used for communication, are gaining attention for their potential to enhance GNSS navigation. By leveraging their low altitude and large-scale constellations, LEO satellites can improve navigation signal availability, reliability, and precision. However, their use for navigation introduces unique challenges. This essay explores the main difficulties of using LEO satellites for GNSS navigation.


### **1. Signal Frequency and Bandwidth Constraints**
One significant challenge is the lack of available spectrum for LEO navigation signals. The L-band, heavily used by GNSS systems, has no remaining frequency resources. To ensure compatibility, LEO systems must minimize interference with GNSS signals by managing signal power and suppressing out-of-band emissions. These limitations complicate LEO system design and require careful coordination to avoid disrupting existing satellite navigation services.  

### **2. High-Dynamic Signal Characteristics**
The low altitude and high speed of LEO satellites result in rapid Doppler shifts and acceleration changes in navigation signals. These dynamic characteristics require ground receivers to maintain high tracking sensitivity, which complicates receiver design. Signal stability is also a challenge due to the satellites' fast movement, necessitating advanced algorithms to ensure reliable tracking.  


### **3. Orbit Management and Constellation Control**
LEO navigation systems require large constellations, often consisting of hundreds or thousands of satellites, which create operational challenges. Managing inter-satellite links, maintaining constellation stability, and optimizing ground station operations become increasingly complex. Effective mechanisms for resource allocation, fault recovery, and load balancing are essential to ensure stable and uninterrupted service.  

### **4. Navigation Signal Error Modeling**
LEO satellites experience unique orbital forces, such as atmospheric drag and gravity variations, which make existing GNSS error models unsuitable. Additionally, LEO navigation payloads exhibit time-varying hardware delays, requiring the development of new error models. These challenges must be addressed to deliver accurate and reliable navigation signals.  

### **5. Integration with GNSS Systems**
LEO satellites augment GNSS systems by enhancing signal availability and providing redundancy. However, seamless integration requires aligning time and spatial references between LEO and GNSS systems. LEO satellites also serve dual roles as independent signal sources and GNSS backups, necessitating optimized system architectures for interoperability and autonomous operations.  

### **6. Communication and Navigation Signal Integration**
Integrating navigation capabilities into communication-focused LEO satellites presents technical challenges. Communication systems prioritize bandwidth and data rates, while navigation systems require signal stability and precision. Achieving this balance requires advanced signal fusion techniques and careful protocol design to meet the needs of both applications.  

### **7. Challenges in Accelerating PPP Convergence**
LEO satellites can significantly accelerate Precise Point Positioning (PPP) convergence. Simulations show that a constellation of 288 LEO satellites can reduce PPP convergence time from 7.1 minutes to 0.7 minutes. However, this improvement depends on the number of visible satellites and requires precise orbital models and real-time corrections to achieve efficient ambiguity resolution.  

### **Conclusion**
LEO satellites offer significant potential to enhance GNSS navigation by improving precision, reliability, and convergence times. They can support GNSS integrity monitoring and provide robust anti-jamming capabilities. However, challenges such as spectrum constraints, high-dynamic signal characteristics, constellation management, and system integration must be addressed. Further research and technological advancements will enable LEO satellites to play a critical role in future navigation systems.

### **References**
1. 王磊, 李德仁, 陈锐志, 等. 低轨卫星导航增强技术——机遇与挑战[J]. 中国工程科学, 2020, 22(2): 144-152.
2. Fossa C E, Raines R A, Gunsch G H, et al. An overview of the IRIDIUM (R) low Earth orbit (LEO) satellite system[C]//Proceedings of the IEEE 1998 National Aerospace and Electronics Conference. NAECON 1998. Celebrating 50 Years (Cat. No. 98CH36185). IEEE, 1998: 152-159.
3. Selvan K, Siemuri A, Prol F S, et al. Precise orbit determination of LEO satellites: a systematic review[J]. GPS Solutions, 2023, 27(4): 178. 
