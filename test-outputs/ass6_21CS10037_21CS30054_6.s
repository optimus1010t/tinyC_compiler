	.globl	counter
	.data
	.align	4
	.type	counter, @object
	.size	counter, 4
counter:
	.long	0
.section	.rodata
.LC0:
	.string "Enter n for testing Collatz conjecture on it (n < 20): "
.LC1:
	.string "Input a positive integer\n"
.LC2:
	.string "Number of steps required to reach 1 in Collatz conjecture: "
.LC3:
	.string "\n"
# printStr: 
# printInt: 
# readInt: 
# t0 = 0
# counter = t0
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$160, %rsp
# param .LC0
# t1 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -20(%rbp)
	addq	$4, %rsp
# t2 = &reader
	leaq	-8(%rbp), %rax
	movq	%rax, -32(%rbp)
# param t2
# t3 = call readInt, 1
	movq	-32(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	readInt
	movq	%rax, -36(%rbp)
	addq	$8, %rsp
# n = t3
	movl	-36(%rbp), %eax
	movl	%eax, -4(%rbp)
# t4 = 0
	movl	$0, -44(%rbp)
# t5 = 1
	movl	$1, -48(%rbp)
# if n == t4 goto .L0
	movl	-4(%rbp), %eax
	cmpl	-44(%rbp), %eax
	jne	.L7
	jmp	.L0
.L7:
# t5 = 0
	movl	$0, -48(%rbp)
# goto .L1
	jmp	.L1
# goto .L1
	jmp	.L1
# param .LC1
.L0:
# t6 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -56(%rbp)
	addq	$4, %rsp
# t7 = 0
	movl	$0, -60(%rbp)
# return t7
	movq	-60(%rbp), %rax
	leave
	ret
# goto .L1
	jmp	.L1
# t8 = 1
.L1:
	movl	$1, -64(%rbp)
# t9 = 1
	movl	$1, -68(%rbp)
# if n != t8 goto .L2
	movl	-4(%rbp), %eax
	cmpl	-64(%rbp), %eax
	je	.L8
	jmp	.L2
.L8:
# t9 = 0
	movl	$0, -68(%rbp)
# goto .L3
	jmp	.L3
# goto .L3
	jmp	.L3
# t10 = 2
.L2:
	movl	$2, -72(%rbp)
# t11 = n % t10
	movl	-4(%rbp), %eax
	cltd
	idivl	-72(%rbp)
	movl	%edx, -76(%rbp)
# t12 = 0
	movl	$0, -80(%rbp)
# t13 = 1
	movl	$1, -84(%rbp)
# if t11 == t12 goto .L4
	movl	-76(%rbp), %eax
	cmpl	-80(%rbp), %eax
	jne	.L9
	jmp	.L4
.L9:
# t13 = 0
	movl	$0, -84(%rbp)
# goto .L5
	jmp	.L5
# goto .L6
	jmp	.L6
# t14 = 2
.L4:
	movl	$2, -88(%rbp)
# t15 = n / t14
	movl	-4(%rbp), %eax
	cltd
	idivl	-88(%rbp)
	movl	%eax, -92(%rbp)
# n = t15
	movl	-92(%rbp), %eax
	movl	%eax, -4(%rbp)
# goto .L6
	jmp	.L6
# t16 = 3
.L5:
	movl	$3, -96(%rbp)
# t17 = t16 * n
	movl	-96(%rbp), %eax
	imull	-4(%rbp), %eax
	movl	%eax, -100(%rbp)
# t18 = 1
	movl	$1, -104(%rbp)
# t19 = t17 + t18
	movl	-100(%rbp), %eax
	movl	-104(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -108(%rbp)
# n = t19
	movl	-108(%rbp), %eax
	movl	%eax, -4(%rbp)
# goto .L6
	jmp	.L6
# t20 = counter
.L6:
	movl	counter(%rip), %eax
	movl	%eax, -116(%rbp)
# counter = counter + 1
	movl	counter(%rip), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, counter(%rip)
# goto .L1
	jmp	.L1
# param .LC2
.L3:
# t21 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -124(%rbp)
	addq	$4, %rsp
# param counter
# t22 = call printInt, 1
	movq	counter(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -132(%rbp)
	addq	$4, %rsp
# param .LC3
# t23 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -140(%rbp)
	addq	$4, %rsp
# t24 = 0
	movl	$0, -144(%rbp)
# return t24
	movq	-144(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
