# AAE6102_Assignment2_ZhangYuanyuan_23037185R

# Task 1 – Differential GNSS Positioning
    Model: ChatGPT 4o
    
    Prompt: Please summarize the pros and cons of the following GNSS techniques for smartphone navigation based on the literature I provide below.
    
    Chatroom Link (if any): [https://chatgpt.com/share/680efc0d-008c-8000-bc38-d1e5433d681f](https://poe.com/s/rd3JLbsm3gqMDLWx2OEN)

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

### **References**
1. Cheng S, Wang F, Li G, et al. Single-frequency multi-GNSS PPP-RTK for smartphone rapid centimeter-level positioning [J]. *IEEE Sensors Journal*, 2023, 23(18): 21553-21561.  
2. Li X, Huang J, Li X, et al. Review of PPP–RTK: Achievements, challenges, and opportunities [J]. *Satellite Navigation*, 2022, 3(1): 28.


# Task 2 -  GNSS Positioning Optimization in Urban Environment

## Implementation Methods

The skymask data, provided in `skymask_A1_urban.csv`, was used to describe building obstruction and its impact on satellite visibility. The skyplot analysis reveals that obstruction mainly affects satellites in the southern and western skies, with available satellites concentrated in the northeast direction. This information was critical for filtering out low-elevation satellites, thereby improving positioning accuracy while reducing multipath errors.

![image](./images/Skyplot.fig)
*Figure 1: Satellite Skyplot with Urban Mask showing visibility constraints.*

Positioning optimization was achieved through a combination of satellite selection and adaptive filtering. The skymask effects were considered to prioritize satellites with favorable geometry, as indicated by low Dilution of Precision (DOP) values. The average HDOP and PDOP values, both at 9.14, reflect the geometric quality of selected satellites. 

![image](https://github.com/ZyyFLY/AAE6102-Assignment2/tree/main/images/DOP.png) 
*Figure 2: Dilution of Precision showing geometric quality.*

An Extended Kalman Filter (EKF) was implemented with a state vector comprising position (x, y, z) and velocity (vx, vy, vz). The filter was enhanced with adaptive noise adjustment and outlier detection mechanisms, further improving the robustness of the system.

## Experimental Results

### 1）Positioning Accuracy
The 3D positioning error statistics reveal a mean error of 179.08 m, a standard deviation of 108.38 m, and an RMS error of 208.60 m. Directional errors show an RMS of 192.37 m in the east direction, 41.72 m in the north direction, and 69.04 m in the up direction. 

![image](https://github.com/ZyyFLY/AAE6102-Assignment2/tree/main/images/Position_Error.fig) 
*Figure 3: Position Error in East, North, and Up directions.*

The horizontal error distribution indicates that most errors fall between 50–200 meters, while 3D errors are concentrated in the range of 50–250 meters. These distributions approximate a normal curve, reflecting the reliability of the positioning system.

![image](https://github.com/ZyyFLY/AAE6102-Assignment2/tree/main/images/error_dis.fig) 
*Figure 4: Horizontal and 3D Error Distribution.*

### 2）Velocity Estimation
The velocity estimation results indicate an average horizontal velocity of 2.87 ± 2.23 m/s in the x direction and -0.04 ± 1.06 m/s in the y direction, with an overall mean speed of 3.22 ± 1.97 m/s. The results show stable velocity estimates over time, with fluctuations primarily occurring in the initial epochs. The velocity estimates align well with expected motion characteristics.

![image](https://github.com/ZyyFLY/AAE6102-Assignment2/tree/main/images/vel.fig) 
*Figure 5: Velocity Components and Magnitude.*

### 3）Performance Analysis
The DOP analysis shows initial values around 15, with significant improvements during epochs 3–4 and stabilization at lower levels in later epochs. Trajectory analysis confirms that the estimated path follows the actual ground track, despite urban environment challenges.

![image](https://github.com/ZyyFLY/AAE6102-Assignment2/tree/main/images/ground.fig) 
*Figure 6: Satellite View with Ground Track showing the estimated path.*

## Key Performance Indicators
Position error distribution demonstrates significant improvements, with reduced horizontal and 3D errors over time. The velocity estimation results show good consistency, with fluctuations diminishing in the later phases of the experiment. The DOP values indicate enhanced satellite geometry, which directly contributes to the observed accuracy improvements.

## Conclusions
This experiment optimized GNSS positioning in an urban environment by integrating skymask data and implementing an EKF. The system effectively handled signal blockage and multipath effects, achieving acceptable positioning and velocity estimation results. The positioning accuracy and reliability meet the general requirements for urban applications.

The advantages of this approach include the incorporation of real urban obstruction effects, improved positioning accuracy over time, and stable velocity estimation performance. Notable characteristics include better accuracy in the north direction compared to the east and improved positioning continuity.

## Key Results Summary
Kalman Filter Results Summary:
- Position Error Statistics:
  - Mean Error: 207.35 m
  - Standard Deviation: 41.60 m
  - RMS Error: 211.37 m
- Velocity Statistics:
  - Mean Velocity X: 2.87 m/s
  - Mean Velocity Y: -0.04 m/s
  - Std Velocity X: 2.23 m/s
  - Std Velocity Y: 1.06 m/s
  - Mean Speed: 3.22 m/s
  - Speed Std Dev: 1.97 m/s
- Detailed Position Error Statistics:
  - East Error (m): Mean: -153.83, Std: 117.02, RMS: 192.37
  - North Error (m): Mean: -34.63, Std: 23.57, RMS: 41.72
  - Up Error (m): Mean: -36.95, Std: 59.09, RMS: 69.04
  - 2D Error (m): Mean: 167.09, Std: 105.41, RMS: 196.84
  - 3D Error (m): Mean: 179.08, Std: 108.38, RMS: 208.60
- Average HDOP: 9.14
- Average PDOP: 9.14

# Task 3 -GNSS RAIM Integrity Monitoring and Stanford Chart Analysis
 
## Key Algorithms and Formulas

1. Weighted Least Squares (WLS) Positioning

```math
X=(H^TWH)^{-1}H^TWZ
```

2. The WSSE can be written as

```math
WSSE=\sqrt{Z^TW(I-P)Z}
```
where P is the weighted projection function

```math
P=H(H^TWH)^{-1}H^TW
```

3. To detect outlier, the threshold T is given as:

```math
T(N,P_{FA})=\sqrt{Q_{\chi^2,N-4 }(1-P_{FA})}

```
where Q is the quantile function of Chi-square distribution with degree of freedom of N-4. 

4. Then the protection level can be calculated by:

```math
PL=max[P_{slope}]T(N,P_{FA})+k(P_{MD})\sigma
```
where P\_slope is the residual slope related to the outlier:

```math
P_{slope} =\frac{\sqrt{K^2_{1,i}+K^2_{2,i}+K^2_{3,i}}}{\sqrt{W_{ii}(1-P_{ii})}}
```
## Main Code Structure

### 1. RAIM Weighted Least Squares Function

```matlab
 % snapshot test statistic
          r = omc - A*x;  % Calculate the residuals
          sse = sqrt(r' * C * r);  % Calculate the sum of squared errors
          dof = length(current_sats) - 4;  % Degrees of freedom

        % chi value
         idx = find(chi2_table(:,1) == length(current_sats), 1);
         if isempty(idx)
          chi2_threshold = chi2inv(1-alpha, dof);  % Calculate chi-squared threshold
         else
          chi2_threshold = chi2_table(idx,2);  % Retrieve threshold from chi-squared table
         end

        % fault detection
         if sse > chi2_threshold
         % find fault
         normalized_res = abs(r) ./ sqrt(diag(inv(C)));  % Normalize residuals
         [~, worst_sat_idx] = max(normalized_res);  % Find the satellite with the maximum normalized residual
          worst_sat = current_sats(worst_sat_idx);
    
          fprintf('Fault detected (SSE=%.3f > threshold=%.3f)\n', sse, chi2_threshold);
          fprintf('Excluding satellite %d (normalized residual=%.3f)\n', worst_sat, max(normalized_res));
    
        % Update satellite list
        faulty_sats = [faulty_sats, worst_sat];  % Add the faulty satellite to the list
        current_sats = setdiff(current_sats, worst_sat);  % Remove the faulty satellite from current satellites
        else
        fprintf('RAIM validation passed (SSE=%.3f <= threshold=%.3f)\n', sse, chi2_threshold);
        break;  % Exit the RAIM loop
        end
```
Compute the 3D protection level (PL) with a probability of false alarm (P_fa) of \(10^{-2}\) and missed detection (P_md) of \(10^{-7}\). Use a GPS pseudorange measurement sigma (σ) of 3m.

```matlab
     %  1. Calculate the projection matrix (using the current A matrix and weights)
   
         m = length(current_sats)+1;
         S = (A' * C * A) \ (A' * C);
         P = A*S;
         
      % 2. Calculate the 3D slope of each satellite
         Slope_3D = zeros(m, 1);
        for i = 1:m
        Slope_3D(i) = sqrt(S(1,i)^2 + S(2,i)^2 + S(3,i)^2) / sqrt(P(i,i));
       end
      
       Slope_3D_max = max(Slope_3D);

     % 3. Get the chi-square threshold (use the same threshold table as RAIM detection)
       idx = find(chi2_table(:,1) == m, 1);
       if isempty(idx)
       T = chi2inv(1-alpha, m-4);
      else
       T = chi2_table(idx,2);
       end

     % 4. Calculate the RMS of the position error
      cov_xyz = inv(A' * C * A);
      RMS_3D = sqrt(cov_xyz(1,1) + cov_xyz(2,2) + cov_xyz(3,3));

    % Step 2: Compute k_md (Gaussian inverse)
     P_md=1e-7;
     k_md = norminv(1 - P_md/2);   % ≈ 5.33 for P_md=1e-7

     k_3D = 3.0;  
     PL = Slope_3D_max * T + k_3D * k_md ;

     fprintf('Protection level calculation: PL_3D = %.2f meters (maximum slope=%.2f, RMS=%.2f)\n',...
     PL, Slope_3D_max, RMS_3D);

     fprintf('Calculate protection level: PL = %.2f meters\n', PL);
```

Evaluate GNSS integrity monitoring performance using a Stanford Chart analysis with a 3D alarm limit (AL) of 50 meters.


# Task 4 – LEO Satellites for Navigation

    Model: ChatGPT 4o
    
    Prompt: Please sort out the difficulties and challenges in navigation of low-orbit satellites mentioned in the following literature.
    
    Chatroom Link (if any): [https://chatgpt.com/share/680efc0d-008c-8000-bc38-d1e5433d681f](https://poe.com/s/rd3JLbsm3gqMDLWx2OEN)

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

# Task 5 – GNSS Remote Sensing: GNSS Reflectometry (GNSS-R)
  Model: ChatGPT 4o
    
    Prompt: Based on the references provided, please describe the current status of GNSS Reflectometry (GNSS-R) applications in GNSS navigation.
    
    Chatroom Link (if any): [https://chatgpt.com/share/680efc0d-008c-8000-bc38-d1e5433d681f](https://poe.com/s/rd3JLbsm3gqMDLWx2OEN)
    
## Introduction
Global Navigation Satellite Systems (GNSS) are not only central to positioning and navigation but also play a transformative role in remote sensing. Among the emerging GNSS-based remote sensing techniques, GNSS Reflectometry (GNSS-R) has gained significant attention for its diverse applications in studying the Earth’s surface and atmosphere. GNSS-R utilizes the reflected signals from GNSS satellites to monitor key environmental parameters. With the advent of spaceborne GNSS-R missions, the technology has demonstrated unique advantages, including high spatial and temporal resolution, low observation cost, wide coverage, and all-weather capabilities. This essay explores the impact of GNSS-R in land remote sensing (RS), focusing on its applications, advancements, and challenges.

## Advantages of GNSS-R Technology
The advantages of GNSS-R technology make it a compelling choice for land remote sensing. First, it offers high spatial and temporal resolution, enabling frequent and detailed observations over large areas. Unlike traditional remote sensing technologies, GNSS-R operates in all weather conditions, as it is less affected by cloud cover or precipitation. Its low observation cost is another advantage, as GNSS satellites are already operational, and the reflectometry payloads are relatively lightweight and inexpensive. Furthermore, GNSS-R signals are naturally immune to interference, making them reliable for a wide range of applications.  

## Challenges in GNSS-R
Despite its potential, GNSS-R faces several challenges that limit its effectiveness. One major issue is the influence of non-target parameters on signal retrieval. Reflected GNSS signals are often affected by environmental factors such as vegetation, surface roughness, and atmospheric conditions, complicating the retrieval of precise information. Another challenge lies in retrieval accuracy improvement. Current algorithms need to be refined to reduce errors and enhance the reliability of derived products.

## Future Directions for GNSS-R
The future of GNSS-R lies in its integration with advanced modeling techniques and multi-source data. For instance, combining GNSS-R with data from other remote sensing platforms, such as optical and radar systems, can provide richer insights into environmental processes. Developing multi-frequency and multi-system GNSS-R instruments will also enhance observation accuracy and reliability. These instruments can exploit signals from multiple GNSS constellations (BeiDou, GPS, GLONASS, Galileo, etc.) to improve spatiotemporal resolution and coverage.

In addition, ground-based and airborne experiments are needed to refine electromagnetic scattering models for L-band signals and validate GNSS-R observations. Innovations in instrument design, such as multi-polarization capabilities, will further improve the quality of GNSS-R data. Moreover, missions like China’s Tianmu-1 constellation and Europe’s HydroGNSS demonstrate the growing global commitment to advancing GNSS-R technology. These efforts will enable GNSS-R to address critical challenges in environmental monitoring, resource management, and disaster mitigation.  


## Conclusion
GNSS-R has emerged as a game-changing technology in land remote sensing, offering unique advantages such as low cost, high resolution, and wide coverage. Its applications in monitoring soil moisture, vegetation, water bodies, and extreme weather events have demonstrated its transformative potential. However, challenges such as retrieval accuracy, data quality, and algorithm development must be addressed to unlock its full potential. With advancements in modeling techniques, multi-system integration, and innovative satellite missions like Tianmu-1, GNSS-R is poised to make significant contributions to environmental research, sustainable development, and disaster preparedness.

### **References**
1. Bu J, Wang Q, Wang Z, et al. Land remote sensing applications using spaceborne GNSS reflectometry: A comprehensive overview[J]. IEEE Journal of Selected Topics in Applied Earth Observations and Remote Sensing, 2024.
2. Yu K, Han S, Bu J, et al. Spaceborne GNSS reflectometry[J]. Remote Sensing, 2022, 14(7): 1605. 
3. Jin S, Komjathy A. GNSS reflectometry and remote sensing: New objectives and results[J]. Advances in Space Research, 2010, 46(2): 111-117.
4. Jin S, Feng G P, Gleason S. Remote sensing using GNSS signals: Current status and future directions[J]. Advances in space research, 2011, 47(10): 1645-1653.
