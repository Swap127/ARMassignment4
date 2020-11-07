     AREA     LogicalGatesOwnImplementation, CODE, READONLY
     EXPORT __main
     IMPORT printMsg
	 IMPORT printMsg2p
	 IMPORT printMsg4p
	 ENTRY 
__main  FUNCTION		         		         		         
     
   	  ;In this code the weights and biases are changed in order to get the correct solution for all the valid input cases for the following gates
	  ; AND,OR,NAND,NOR,NOT
	  ;XOR/XNOR is not done as it requires to make a multilayer perceptron with hidden layers to get the right results and for that new weights,
	  ;biases, number of hidden layers and the number of sigmoid function calculators have to be found out which is not required to be done 
	  ;The any combination of 3-inputs can be entered in the input section and the operation input can also be selected according the gates
	  ;The final answer can be observed in the r0 register or the Debug(printf) viewer
	  
	  
	  ;inputs
	  VLDR.F32 s19, = 1			;input1
	  VLDR.F32 s20, = 0			;input2
	  VLDR.F32 s21, = 0			;input3
	  
	  ;Operation Input
	  VLDR.F32 s0, =0			;the value here can be edited according to the operation that needs to be done
								;0 : AND
								;1 : OR
								;2 : NAND
								;3 : NOR
								;4 : NOT for input1
									
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
	  
AND3	  
	  ;Weights
      VLDR.F32 s15, =1
	  VLDR.F32 s16, =1
	  VLDR.F32 s17, =1
	  
	  ;Bias
	  VLDR.F32 s18, =-2
	  
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

OR3	  
	  ;Weights
      VLDR.F32 s15, =1
	  VLDR.F32 s16, =1
	  VLDR.F32 s17, =1
	  
	  ;Bias
	  VLDR.F32 s18, =-0.9
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

NAND3	  
	  ;Weights
	  VLDR.F32 s15, =-1
	  VLDR.F32 s16, =-1
	  VLDR.F32 s17, =-1
	  
	  ;Bias
	  VLDR.F32 s18, =3
	  ;threshold
	  VLDR.F32 s23, =0.5
	  B Calx

NOR3	  
	  ;Weights
      VLDR.F32 s15, =-1
	  VLDR.F32 s16, =-1
	  VLDR.F32 s17, =-1
	  
	  ;Bias
	  VLDR.F32 s18, = 1
	  ;threshold
	  VLDR.F32 s23, =0.51
	  B Calx
	  

NOT1	  
	  ;Weight
      VLDR.F32 s15, =-1
	 
	  ;Bias
	  VLDR.F32 s18, = 1
	  ;threshold
	  VLDR.F32 s23, =0.51
	  B CalxNOT


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
	  VMOV.F32 s3, s22              ;Loading the value(x) whose sigmoid has to be calculated	 
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
	  END
									   ;for checking the program the value for any value just store the number in s3 and the number of
									   ;summation terms in s1(if limited number of terms is required) in the starting and at the end of the program the final value can be observed
									   ;in s11
									   ;My program runs perfectly for both the cases infinite terms and finite terms
									   ;s12 represents the number of iterations done (or the term upto which the calculation is done)