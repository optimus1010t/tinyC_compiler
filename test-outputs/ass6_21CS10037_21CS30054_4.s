.section	.rodata
.LC0:
	.string "Array is:"
.LC1:
	.string " "
.LC2:
	.string "\n"
.LC3:
	.string "Maximum contiguous sum is "
.LC4:
	.string "\n"
# printStr: 
# printInt: 
# readInt: 
# maxSubArrSum: 

	.text
	.globl	maxSubArrSum
	.type	maxSubArrSum, @function
maxSubArrSum:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$80, %rsp
# t0 = 1000
	movl	$1000, -4(%rbp)
# t1 = -t0
	movl	-4(%rbp), %eax
	negl	%eax
	movl	%eax, -8(%rbp)
# t2 = 0
	movl	$0, -12(%rbp)
# max_so_far = t1
	movl	-8(%rbp), %eax
	movl	%eax, -16(%rbp)
# max_ending_here = t2
	movl	-12(%rbp), %eax
	movl	%eax, -20(%rbp)
# t3 = 0
	movl	$0, -28(%rbp)
# i = t3
	movl	-28(%rbp), %eax
	movl	%eax, -24(%rbp)
# t4 = 1
.L2:
	movl	$1, -32(%rbp)
# if i < n goto .L0
	movl	-24(%rbp), %eax
	cmpl	24(%rbp), %eax
	jge	.L12
	jmp	.L0
.L12:
# t4 = 0
	movl	$0, -32(%rbp)
# goto .L1
	jmp	.L1
# goto .L1
	jmp	.L1
# t5 = i
.L6:
	movl	-24(%rbp), %eax
	movl	%eax, -36(%rbp)
# i = i + 1
	movl	-24(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -24(%rbp)
# goto .L2
	jmp	.L2
# t6 = 0
.L0:
	movl	$0, -40(%rbp)
# t7 = i
	movl	-24(%rbp), %eax
	movl	%eax, -44(%rbp)
# t7 = t7 * 4
	movl	-44(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -44(%rbp)
# t6 = t7
	movl	-44(%rbp), %eax
	movl	%eax, -40(%rbp)
# t8 = a[t6]
	movl	-40(%rbp), %edx
cltq
	movq	16(%rbp), %rdi
	addq	%rdi, %rdx
	movq	(%rdx) ,%rax
	movq	%rax, -48(%rbp)
# t9 = max_ending_here + t8
	movl	-20(%rbp), %eax
	movl	-48(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -52(%rbp)
# max_ending_here = t9
	movl	-52(%rbp), %eax
	movl	%eax, -20(%rbp)
# t10 = 1
	movl	$1, -56(%rbp)
# if max_so_far < max_ending_here goto .L3
	movl	-16(%rbp), %eax
	cmpl	-20(%rbp), %eax
	jge	.L13
	jmp	.L3
.L13:
# t10 = 0
	movl	$0, -56(%rbp)
# goto .L4
	jmp	.L4
# goto .L4
	jmp	.L4
# max_so_far = max_ending_here
.L3:
	movl	-20(%rbp), %eax
	movl	%eax, -16(%rbp)
# goto .L4
	jmp	.L4
# t11 = 0
.L4:
	movl	$0, -60(%rbp)
# t12 = 1
	movl	$1, -64(%rbp)
# if max_ending_here < t11 goto .L5
	movl	-20(%rbp), %eax
	cmpl	-60(%rbp), %eax
	jge	.L14
	jmp	.L5
.L14:
# t12 = 0
	movl	$0, -64(%rbp)
# goto .L6
	jmp	.L6
# goto .L7
	jmp	.L7
# t13 = 0
.L5:
	movl	$0, -68(%rbp)
# max_ending_here = t13
	movl	-68(%rbp), %eax
	movl	%eax, -20(%rbp)
# goto .L6
	jmp	.L6
# goto .L6
.L7:
	jmp	.L6
# return max_so_far
.L1:
	movq	-16(%rbp), %rax
	leave
	ret
# function maxSubArrSum ends
	leave
	ret
	.size	maxSubArrSum, .-maxSubArrSum
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$304, %rsp
# t14 = 8
	movl	$8, -4(%rbp)
# t15 = 0
	movl	$0, -40(%rbp)
# t16 = 0
	movl	$0, -44(%rbp)
# t17 = t15
	movl	-40(%rbp), %eax
	movl	%eax, -48(%rbp)
# t17 = t17 * 4
	movl	-48(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -48(%rbp)
# t16 = t17
	movl	-48(%rbp), %eax
	movl	%eax, -44(%rbp)
# t18 = 20
	movl	$20, -52(%rbp)
# t19 = -t18
	movl	-52(%rbp), %eax
	negl	%eax
	movl	%eax, -56(%rbp)
# a[t16] = t19
	movl	-44(%rbp), %edx
	movl	-56(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t20 = 1
	movl	$1, -60(%rbp)
# t21 = 0
	movl	$0, -64(%rbp)
# t22 = t20
	movl	-60(%rbp), %eax
	movl	%eax, -68(%rbp)
# t22 = t22 * 4
	movl	-68(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -68(%rbp)
# t21 = t22
	movl	-68(%rbp), %eax
	movl	%eax, -64(%rbp)
# t23 = 40
	movl	$40, -72(%rbp)
# t24 = -t23
	movl	-72(%rbp), %eax
	negl	%eax
	movl	%eax, -76(%rbp)
# a[t21] = t24
	movl	-64(%rbp), %edx
	movl	-76(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t25 = 2
	movl	$2, -80(%rbp)
# t26 = 0
	movl	$0, -84(%rbp)
# t27 = t25
	movl	-80(%rbp), %eax
	movl	%eax, -88(%rbp)
# t27 = t27 * 4
	movl	-88(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -88(%rbp)
# t26 = t27
	movl	-88(%rbp), %eax
	movl	%eax, -84(%rbp)
# t28 = 50
	movl	$50, -92(%rbp)
# a[t26] = t28
	movl	-84(%rbp), %edx
	movl	-92(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t29 = 3
	movl	$3, -96(%rbp)
# t30 = 0
	movl	$0, -100(%rbp)
# t31 = t29
	movl	-96(%rbp), %eax
	movl	%eax, -104(%rbp)
# t31 = t31 * 4
	movl	-104(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -104(%rbp)
# t30 = t31
	movl	-104(%rbp), %eax
	movl	%eax, -100(%rbp)
# t32 = 15
	movl	$15, -108(%rbp)
# t33 = -t32
	movl	-108(%rbp), %eax
	negl	%eax
	movl	%eax, -112(%rbp)
# a[t30] = t33
	movl	-100(%rbp), %edx
	movl	-112(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t34 = 4
	movl	$4, -116(%rbp)
# t35 = 0
	movl	$0, -120(%rbp)
# t36 = t34
	movl	-116(%rbp), %eax
	movl	%eax, -124(%rbp)
# t36 = t36 * 4
	movl	-124(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -124(%rbp)
# t35 = t36
	movl	-124(%rbp), %eax
	movl	%eax, -120(%rbp)
# t37 = 25
	movl	$25, -128(%rbp)
# t38 = -t37
	movl	-128(%rbp), %eax
	negl	%eax
	movl	%eax, -132(%rbp)
# a[t35] = t38
	movl	-120(%rbp), %edx
	movl	-132(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t39 = 5
	movl	$5, -136(%rbp)
# t40 = 0
	movl	$0, -140(%rbp)
# t41 = t39
	movl	-136(%rbp), %eax
	movl	%eax, -144(%rbp)
# t41 = t41 * 4
	movl	-144(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -144(%rbp)
# t40 = t41
	movl	-144(%rbp), %eax
	movl	%eax, -140(%rbp)
# t42 = 15
	movl	$15, -148(%rbp)
# a[t40] = t42
	movl	-140(%rbp), %edx
	movl	-148(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t43 = 6
	movl	$6, -152(%rbp)
# t44 = 0
	movl	$0, -156(%rbp)
# t45 = t43
	movl	-152(%rbp), %eax
	movl	%eax, -160(%rbp)
# t45 = t45 * 4
	movl	-160(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -160(%rbp)
# t44 = t45
	movl	-160(%rbp), %eax
	movl	%eax, -156(%rbp)
# t46 = 65
	movl	$65, -164(%rbp)
# a[t44] = t46
	movl	-156(%rbp), %edx
	movl	-164(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# t47 = 7
	movl	$7, -168(%rbp)
# t48 = 0
	movl	$0, -172(%rbp)
# t49 = t47
	movl	-168(%rbp), %eax
	movl	%eax, -176(%rbp)
# t49 = t49 * 4
	movl	-176(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -176(%rbp)
# t48 = t49
	movl	-176(%rbp), %eax
	movl	%eax, -172(%rbp)
# t50 = 690
	movl	$690, -180(%rbp)
# t51 = -t50
	movl	-180(%rbp), %eax
	negl	%eax
	movl	%eax, -184(%rbp)
# a[t48] = t51
	movl	-172(%rbp), %edx
	movl	-184(%rbp), %eax
cltq
	movl	%eax, -36(%rbp,%rdx,1)
# param .LC0
# t52 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -196(%rbp)
	addq	$4, %rsp
# t53 = 0
	movl	$0, -204(%rbp)
# i = t53
	movl	-204(%rbp), %eax
	movl	%eax, -200(%rbp)
# t54 = 8
.L10:
	movl	$8, -208(%rbp)
# t55 = 1
	movl	$1, -212(%rbp)
# if i < t54 goto .L8
	movl	-200(%rbp), %eax
	cmpl	-208(%rbp), %eax
	jge	.L15
	jmp	.L8
.L15:
# t55 = 0
	movl	$0, -212(%rbp)
# goto .L9
	jmp	.L9
# goto .L9
	jmp	.L9
# t56 = i
.L11:
	movl	-200(%rbp), %eax
	movl	%eax, -216(%rbp)
# i = i + 1
	movl	-200(%rbp), %eax
	movl	$1, %edx
	addl	%edx, %eax
	movl	%eax, -200(%rbp)
# goto .L10
	jmp	.L10
# param .LC1
.L8:
# t57 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -224(%rbp)
	addq	$4, %rsp
# t58 = 0
	movl	$0, -232(%rbp)
# t59 = i
	movl	-200(%rbp), %eax
	movl	%eax, -236(%rbp)
# t59 = t59 * 4
	movl	-236(%rbp), %eax
	imull	$4, %eax
	movl	%eax, -236(%rbp)
# t58 = t59
	movl	-236(%rbp), %eax
	movl	%eax, -232(%rbp)
# t60 = a[t58]
	movl	-232(%rbp), %edx
cltq
	movl	-36(%rbp,%rdx,1), %eax
	movl	%eax, -240(%rbp)
# param t60
# t61 = call printInt, 1
	movq	-240(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -244(%rbp)
	addq	$4, %rsp
# goto .L11
	jmp	.L11
# param .LC2
.L9:
# t62 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -252(%rbp)
	addq	$4, %rsp
# t64 = 8
	movl	$8, -264(%rbp)
# param a
# param t64
# t65 = call maxSubArrSum, 2
	movq	-264(%rbp), %rax
	pushq	%rax
	movq	%rax, %rsi
	leaq	-36(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	maxSubArrSum
	movq	%rax, -268(%rbp)
	addq	$12, %rsp
# max_subArr_sum = t65
	movl	-268(%rbp), %eax
	movl	%eax, -272(%rbp)
# param .LC3
# t66 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -280(%rbp)
	addq	$4, %rsp
# param max_subArr_sum
# t67 = call printInt, 1
	movq	-272(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -284(%rbp)
	addq	$4, %rsp
# param .LC4
# t68 = call printStr, 1
	movq	$.LC4, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -292(%rbp)
	addq	$4, %rsp
# t69 = 0
	movl	$0, -296(%rbp)
# return t69
	movq	-296(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
