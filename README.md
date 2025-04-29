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



## **Task 4: Position and Velocity Estimation**

### **Objective**
Using pseudorange measurements from tracking, implement the Weighted Least Squares (WLS) algorithm to compute the user's position and velocity.

### **1. Open-sky**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/wls-open.png)  
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/open-v.png)  
- 

### **2. Urban**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/wls-urban.png) 
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/urban-v.png)  

### **Results**
- In an open environment, the weighted least squares method (WLS) is used to estimate the position and velocity. The results show that the position deviation is small, the velocity changes smoothly, the amplitude of the three-dimensional components is consistent, and the accuracy is high.
- In an urban environment, multipath effects and occlusions cause the position deviation to increase, the velocity estimation fluctuates violently, and the amplitude is uneven, the error increases significantly, and the algorithm performance is affected.


## **Task 5:Kalman Filter-Based Positioning**

### **Objective**
Develop an Extended Kalman Filter (EKF) using pseudorange and Doppler measurements to estimate user position and velocity.

### **1. Open-sky**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/ekf-open.png)  
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/open-v-ekf.png)  
- 

### **2. Urban**
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/ekf-urban.png) 
![image](https://github.com/ZyyFLY/AAE6102-Assignment-1-ZhangYuanyuan/blob/main/images/urban-v-ekf.png) 

### **Results**
-In an open environment, the Extended Kalman Filter (EKF) algorithm performs stably on position and velocity estimation, with small position changes, moderate velocity amplitude and stable fluctuations, and can effectively track user dynamics.

-In an urban environment, due to multipath effects and occlusion, the EKF shows obvious errors, dramatic and unstable position changes, and abnormally high values ​​of velocity estimation, indicating that environmental noise has a greater impact on filter performance.
