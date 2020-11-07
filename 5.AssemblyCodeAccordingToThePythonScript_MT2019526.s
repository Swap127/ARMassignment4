     AREA     LogicalGatesPyhtonScript, CODE, READONLY
     EXPORT __main
     IMPORT printMsg
	 IMPORT printMsg2p
	 IMPORT printMsg4p
	 ENTRY 
__main  FUNCTION		         		         		         
     
   	  ;In this code the weights and biases are not changed are in order as given in the python script
	  ;Although I have adjusted the threshold to get the right results
	  ;The combination of 3-inputs are in the datasets at the end of program which is same as given in the python script
	  ;The final answer can be observed in the r0 register or the Debug(printf) viewer
	  
	  
	  ;inputs
	  ADR r1, TestDataset1		;Edit the name of the dataset to change the dataset
	  VLDR.F32 s19,[r1]			;input1
	  VLDR.F32 s20,[r1,#4]	   	;input2
	  VLDR.F32 s21,[r1,#8]		;input3
	  
	  ;Operation Input
	  VLDR.F32 s0, =0			;the value here can be edited according to the operation that needs to be done
								;0 : AND
								;1 : OR
								;2 : NAND
								;3 : NOR
								;4 : NOT for input1
								;5 : XOR/XNOR 	
								
	  ;Selecting the order of instructions according to the operation that is required to be done
   	  VLDR.F32 s31, =0
	  VCMP.F32 s0, s31
	  VMRS    APSR_nzcv, FPSCR
		BLE AND3
	  VLDR.F32 s31, =1
	  VCMP.F32 s0,s31 
	  VMRS    APSR_nzcv, FPSCR
		BLE OR3
	  VLDR.F32 s31, =2
	  VCMP.F32 s0,s31 
	  VMRS    APSR_nzcv, FPSCR
		BLE NAND3
	  VLDR.F32 s31, =3
	  VCMP.F32 s0,s31 
	  VMRS    APSR_nzcv, FPSCR
		BLE NOR3
	  VLDR.F32 s31, =4
	  VCMP.F32 s0,s31 
	  VMRS    APSR_nzcv, FPSCR
		BLE NOT1
	  VLDR.F32 s31, =5
	  VCMP.F32 s0,s31 
	  VMRS    APSR_nzcv, FPSCR
		BLE XORXNOR3
	  
	  
AND3	  
	  ;Weights
      VLDR.F32 s15, =-0.1
	  VLDR.F32 s16, =0.2
	  VLDR.F32 s17, =0.2
	  
	  ;Bias
	  VLDR.F32 s18, =-0.2
	  
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

OR3	  
	  ;Weights
      VLDR.F32 s15, =-0.1
	  VLDR.F32 s16, =0.7
	  VLDR.F32 s17, =0.7
	  
	  ;Bias
	  VLDR.F32 s18, =-0.1
	  ;threshold
	  VLDR.F32 s23, =0.4
	  B Calx

NAND3	  
	  ;Weights
	  VLDR.F32 s15, =0.6
	  VLDR.F32 s16, =-0.8
	  VLDR.F32 s17, =-0.8
	  
	  ;Bias
	  VLDR.F32 s18, =0.3
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

NOR3	  
	  ;Weights
      VLDR.F32 s15, =0.5
	  VLDR.F32 s16, =-0.7
	  VLDR.F32 s17, =-0.7
	  
	  ;Bias
	  VLDR.F32 s18, = 0.1
	  ;threshold
	  VLDR.F32 s23, =0.7
	  B Calx
	  

NOT1	  
	  ;Weight
      VLDR.F32 s15, =-0.7
	 
	  ;Bias
	  VLDR.F32 s18, = 0.1
	  ;threshold
	  VLDR.F32 s23, =0.51
	  B CalxNOT

XORXNOR3	;The python code also does not work properly for the XNOR/XOR and it requires a multilayer perceptron and hidden layers to work correctly
			;The XOR/XNOR part of the python has been commented in the orignal code maybe beacause it won't work properly because of the above reason
	  ;Weights
      VLDR.F32 s15, =-5
	  VLDR.F32 s16, =20
	  VLDR.F32 s17, =10
	  
	  ;Bias
	  VLDR.F32 s18, = 1
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

CalxNOT
	  VMUL.F32 s22,s15,s19
	  VADD.F32 s22,s22,s18
	  B CalSig
Calx		
	  ;Calculating the value of x
	  VMUL.F32 s22,s15,s19
	  VFMA.F32 s22,s16,s20
	  VFMA.F32 s22,s17,s21
	  VADD.F32 s22,s22,s18
	  B CalSig


CalSig
	  LDR r1, =0x7f800000                 
	  VMOV.F32 s1,r1				   ;to load s1 with infinity as it represents infinite terms (t)
	  ;if a limited number of terms are required for the calculation then uncomment the below instruction adn load the number of terms and comment the above 2 instructions
	  ;VMOV.F32 s1, #10                ;s1 stores the value of the number of terms(t) upto which the sum will be calculated
	  VMOV.F32 s2, #1                  ;storing the value 1(constant) in s2
	  VMOV.F32 s3, s22                 ;Loading the value(x) whose sigmoid has to be calculated	 
   	  VMOV.F32 s4, #-1            	   ;Loading the initial value with -1 in s4
	  VMOV.F32 s5, #1				   ;Loading the initial value with 1 for the variable which increaments for the LOOP
	  VMOV.F32 s7, #1                  ;Loading the initial value with 1  for storing multiplication output
	  VNEG.F32 s8,s3                   ;for getting the negative value as according to my method negative value i.e (-x) is required
	  
LOOP  VCMP.F32 s1,s5                   ;Comparing between the upper limit and the loop variable respectively
      VMRS    APSR_nzcv, FPSCR         ;VMRS instruction is used to transfer the flags from the FPSCR to the APSR
	  VMULGE.F32 s7,s7,s8              ;(-x)^n is calculated and stored in s7
	  VMOVGE.F32 s12,s5 			   ; load the current term number n into s12
	  BGE LOOP2
     
LOOP4 VCMP.F32 s1,s5                   ;Comparing between the upper limit and the loop variable respectively
      VMRS    APSR_nzcv, FPSCR
	  VDIVNE.F32 s9,s7,s14             ;((-x)^n/n!)
	  VSUBNE.F32 s4,s4,s9              ;accumulation of all the terms is done and stored  
	  VADDNE.F32 s5, s5, s2 		   ;increament n(increamenting loop)
	  
	  VCMPNE.F32 s15,s4                ;Comparing between the previous s4 and new s4 value if it is same then the value has stopped changing therefore no more iterations are required
      VMRS    APSR_nzcv, FPSCR          
      VMOVNE.F32 s15,s4         	   ;Moving the value of s4 in s15 till one gets the same value for both iterations 
	  BNE LOOP 					       ;run the loop again
     
	  VMOV.F32 s10,s4                  ;The value(p) is which is calculated from the ln(x) by changing the denominator by integer factorial value instead of the integers is transfered from s4 to s10 	  
	  VLDR.F32 s11, =1                 ;s11 is initially loaded with 1
	  VSUB.F32 s11,s11,s10			   ;1-p is done is s11
	  VDIV.F32 s11,s2,s11     		   ;The value of sig(x) is evaluated by dividing 1 by stored in s11 and finally stored in s11 again 	  
									   ;The final value of s11 can be observed in s11 after the end of the program 

	  
	  VCMP.F32 s11,s23
	  VMRS    APSR_nzcv, FPSCR
	  ITE LT
		MOVLT r0, #0x0
		MOVGE r0, #0x1
	  BL printMsg

stopProgram    B stopProgram           ;to stop the program
	 	 									  
      ;Factorial
LOOP2 VMOV.F32 s13, #1  			   ;if n = 0, at least n! = 1 
   	  VMOV.F32 s14, #1
	  B LOOP3
	  
LOOP3 VCMP.F32 s13, s12
      VMRS    APSR_nzcv, FPSCR
	  VMULLE.F32 s14, s13, s14
      VADDLE.F32 s13, s13, s2          ;increament n
      BLE LOOP3                        ;do another mul
	  B LOOP4
	  
      ENDFUNC
	  ALIGN
	; Test Data sets as given in the python script
TestDataset1
	 DCD 0x3f800000 ;1
	 DCD 0x00000000 ;0
	 DCD 0x00000000 ;0
		 
TestDataset2
	 DCD 0x3f800000 ;1
	 DCD 0x00000000 ;0
	 DCD 0x3f800000 ;1
		 
TestDataset3
	 DCD 0x3f800000 ;1
	 DCD 0x3f800000 ;1
	 DCD 0x00000000 ;0
		 
TestDataset4
	 DCD 0x3f800000 ;1
	 DCD 0x3f800000 ;1
	 DCD 0x3f800000 ;1
	  
	  
	 END
									   
	 
		 
		 