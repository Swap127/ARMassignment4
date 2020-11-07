     AREA     Sigmoid, CODE, READONLY
     EXPORT __main
	 ENTRY 
__main  FUNCTION		         

      ;Calculating the value if sigmoid(0.5) upto infinite(or finite) terms
	  ;e^(-x) = 1 - x + ((x^2)/2) - ((x^3)/3!) + ((x^4)/4!) - ((x^5)/5!) +.....
	  ;sigmoid(x) = 1/(1+e^(-x))
	  ;Therefore, sigmoid(0.5) = 0.622459
	  ;I had analyzed the taylor series equation and reduced it to summation from 1 to n: out = [out - (((-(1-x))^n)/n)] in the last assignment for calculation the ln(1+x) value
      ;So I did changes and added the required code for the division by factorial and did other required changes to get the correct value
      ;And now the code is running perfectly fine
	  
	  LDR r1, =0x7f800000                 
	  VMOV.F32 s1,r1				   ;to load s1 with infinity as it represents infinite terms (t)
	  ;if a limited number of terms are required for the calculation then uncomment the below instruction adn load the number of terms and comment the above 2 instructions
	  ;VMOV.F32 s1, #10                ;s1 stores the value of the number of terms(t) upto which the sum will be calculated
	  VMOV.F32 s2, #1                  ;storing the value 1(constant) in s2
	  VLDR.F32 s3, =0.5              ;Loading the value(x) whose sigmoid has to be calculated	 
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
     
	  VMOV.F32 s10,s4                  ;The value(p) is which is calculated from the ln(x) by changing the denominator by factorial value is transfered from s4 to s10 	  
	  VLDR.F32 s11, =1                ;s11 is initially loaded with 1
	  VSUB.F32 s11,s11,s10			   ;2-p is done is s11
	  VDIV.F32 s11,s2,s11     		   ;The value of sig(x) is evaluated by dividing 1 by stored in s11 and finally stored in s11 again 	  
									   ;The final value of s11 can be observed in s11 after the end of the program 
	  ;VCVT.U32.F32 s11, s0            ;It can be used to convert the floating point value to unsigned integer and store it in s0
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
									   ;summation terms in s1(if limited number of terms is required) in the starting
									   ;at the end of the program the final value can be observed in s11
									   ;My program runs perfectly for both the cases infinite terms and finite terms
									   ;s12 represents the number of iterations done (or the term upto which the calculation is done)