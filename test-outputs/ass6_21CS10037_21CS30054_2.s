	.globl	global_var
	.data
	.align	4
	.type	global_var, @object
	.size	global_var, 4
global_var:
	.long	0
	.globl	counter
	.data
	.align	4
	.type	counter, @object
	.size	counter, 4
counter:
	.long	0
.section	.rodata
.LC0:
	.string "Enter n (n < 20): "
.LC1:
	.string "fact["
.LC2:
	.string "] = "
.LC3:
	.string "\n"
# printStr: 
.L11:
# printInt: 
# readInt: 
# t0 = 0
# global_var = t0
# t1 = 0
# counter = t1
# factorial: 
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$384, %rsp
# t2 = counter
	movl	counter(%rip), %eax
	movl	%eax, -8(%rbp)
# counter = counter + 1
	movl	counter(%rip), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, counter(%rip)
# global_var = counter
	movl	counter(%rip), %eax
	movl	%eax, global_var(%rip)
# param .LC0
# t3 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -32(%rbp)
	addq	$4, %rsp
# t4 = &reader
	leaq	-20(%rbp), %rax
	movq	%rax, -44(%rbp)
# param t4
# t5 = call readInt, 1
	movq	-44(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	readInt
	movq	%rax, -48(%rbp)
	addq	$8, %rsp
# n = t5
	movl	-48(%rbp), %eax
	movl	%eax, -16(%rbp)
# t6 = 50
	movl	$50, -56(%rbp)
# t7 = 0
	movl	$0, -260(%rbp)
# i = t7
	movl	-260(%rbp), %eax
	movl	%eax, -52(%rbp)
# t8 = 1
.L2:
	movl	$1, -264(%rbp)
# if i < n goto .L0
	movl	-52(%rbp), %eax
	cmpl	-16(%rbp), %eax
	jge	.L12
	jmp	.L0
.L12:
# t8 = 0
	movl	$0, -264(%rbp)
# goto .L1
	jmp	.L1
# goto .L1
	jmp	.L1
# t9 = i
.L3:
	movl	-52(%rbp), %eax
	movl	%eax, -268(%rbp)
# i = i + 1
	movl	-52(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -52(%rbp)
# goto .L2
	jmp	.L2
# t10 = 0
.L0:
	movl	$0, -272(%rbp)
# t11 = i
	movl	-52(%rbp), %eax
	movl	%eax, -276(%rbp)
# t11 = t11 * 4
	movl	-276(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -276(%rbp)
# t10 = t11
	movl	-276(%rbp), %eax
	movl	%eax, -272(%rbp)
# t12 = 1
	movl	$1, -284(%rbp)
# t13 = i + t12
	movl	-52(%rbp), %eax
	movl	-284(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -288(%rbp)
# param t13
# t14 = call factorial, 1
	movq	-288(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	factorial
	movq	%rax, -292(%rbp)
	addq	$4, %rsp
# fact[t10] = t14
	movl	-272(%rbp), %edx
	movl	-292(%rbp), %eax
cltq
	movl	%eax, -256(%rbp,%rdx,1)
# t15 = counter
	movl	counter(%rip), %eax
	movl	%eax, -296(%rbp)
# counter = counter + 1
	movl	counter(%rip), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, counter(%rip)
# global_var = counter
	movl	counter(%rip), %eax
	movl	%eax, global_var(%rip)
# goto .L3
	jmp	.L3
# t16 = 0
.L1:
	movl	$0, -300(%rbp)
# i = t16
	movl	-300(%rbp), %eax
	movl	%eax, -52(%rbp)
# t17 = 1
.L6:
	movl	$1, -304(%rbp)
# if i < n goto .L4
	movl	-52(%rbp), %eax
	cmpl	-16(%rbp), %eax
	jge	.L13
	jmp	.L4
.L13:
# t17 = 0
	movl	$0, -304(%rbp)
# goto .L5
	jmp	.L5
# goto .L5
	jmp	.L5
# t18 = i
.L7:
	movl	-52(%rbp), %eax
	movl	%eax, -308(%rbp)
# i = i + 1
	movl	-52(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -52(%rbp)
# goto .L6
	jmp	.L6
# param .LC1
.L4:
# t19 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -316(%rbp)
	addq	$4, %rsp
# t20 = 1
	movl	$1, -324(%rbp)
# t21 = i + t20
	movl	-52(%rbp), %eax
	movl	-324(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -328(%rbp)
# param t21
# t22 = call printInt, 1
	movq	-328(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -332(%rbp)
	addq	$4, %rsp
# param .LC2
# t23 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -340(%rbp)
	addq	$4, %rsp
# t24 = 0
	movl	$0, -344(%rbp)
# t25 = i
	movl	-52(%rbp), %eax
	movl	%eax, -348(%rbp)
# t25 = t25 * 4
	movl	-348(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -348(%rbp)
# t24 = t25
	movl	-348(%rbp), %eax
	movl	%eax, -344(%rbp)
# t26 = fact[t24]
	movl	-344(%rbp), %edx
cltq
	movl	-256(%rbp,%rdx,1), %eax
	movl	%eax, -352(%rbp)
# param t26
# t27 = call printInt, 1
	movq	-352(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -356(%rbp)
	addq	$4, %rsp
# param .LC3
# t28 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -364(%rbp)
	addq	$4, %rsp
# goto .L7
	jmp	.L7
# t29 = 0
.L5:
	movl	$0, -368(%rbp)
# return t29
	movq	-368(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
# factorial: 

	.text
	.globl	factorial
	.type	factorial, @function
factorial:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$48, %rsp
# t30 = counter
	movl	counter(%rip), %eax
	movl	%eax, -8(%rbp)
# counter = counter + 1
	movl	counter(%rip), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, counter(%rip)
# global_var = counter
	movl	counter(%rip), %eax
	movl	%eax, global_var(%rip)
# t31 = 0
	movl	$0, -16(%rbp)
# t32 = 1
	movl	$1, -20(%rbp)
# if n == t31 goto .L8
	movl	16(%rbp), %eax
	cmpl	-16(%rbp), %eax
	jne	.L14
	jmp	.L8
.L14:
# t32 = 0
	movl	$0, -20(%rbp)
# goto .L9
	jmp	.L9
# goto .L10
	jmp	.L10
# t33 = 1
.L8:
	movl	$1, -24(%rbp)
# return t33
	movq	-24(%rbp), %rax
	leave
	ret
# goto .L11
	jmp	.L11
# t34 = 1
.L9:
	movl	$1, -32(%rbp)
# t35 = n - t34
	movl	16(%rbp), %edx
	movl	-32(%rbp), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -36(%rbp)
# param t35
# t36 = call factorial, 1
	movq	-36(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	factorial
	movq	%rax, -40(%rbp)
	addq	$4, %rsp
# t37 = n * t36
	movl	16(%rbp), %eax
	imull	-40(%rbp), %eax
	movl	%eax, -44(%rbp)
# return t37
	movq	-44(%rbp), %rax
	leave
	ret
# goto .L11
	jmp	.L11
# function factorial ends
.L10:
	leave
	ret
	.size	factorial, .-factorial
