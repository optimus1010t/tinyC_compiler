	.comm	c,1,1
	.comm	i,4,4
	.comm	j,4,4
	.comm	k,4,4
	.comm	l,4,4
	.comm	m,4,4
	.globl	a
	.data
	.align	4
	.type	a, @object
	.size	a, 4
a:
	.long	4
	.comm	b,4,4
.section	.rodata
.LC0:
	.string "Enter x: "
.LC1:
	.string "Enter y: "
.LC2:
	.string "i = "
.LC3:
	.string " + "
.LC4:
	.string " = "
.LC5:
	.string "\n"
.LC6:
	.string "j = "
.LC7:
	.string " - "
.LC8:
	.string " = "
.LC9:
	.string "\n"
.LC10:
	.string "k = "
.LC11:
	.string " * "
.LC12:
	.string " = "
.LC13:
	.string "\n"
.LC14:
	.string "l = "
.LC15:
	.string " / "
.LC16:
	.string " = "
.LC17:
	.string "\n"
.LC18:
	.string "m = "
.LC19:
	.string " % "
.LC20:
	.string " = "
.LC21:
	.string "\n"
# printStr: 
# printInt: 
# readInt: 
# t0 = 6.900000
# d = t0
# t1 = 20
# t2 = 4
# a = t2
# main: 

	.text
	.globl	main
	.type	main, @function
main:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$336, %rsp
# param .LC0
# t3 = call printStr, 1
	movq	$.LC0, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -24(%rbp)
	addq	$4, %rsp
# t4 = &reader
	leaq	-12(%rbp), %rax
	movq	%rax, -36(%rbp)
# param t4
# t5 = call readInt, 1
	movq	-36(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	readInt
	movq	%rax, -40(%rbp)
	addq	$8, %rsp
# x = t5
	movl	-40(%rbp), %eax
	movl	%eax, -4(%rbp)
# param .LC1
# t6 = call printStr, 1
	movq	$.LC1, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -48(%rbp)
	addq	$4, %rsp
# t7 = &reader
	leaq	-12(%rbp), %rax
	movq	%rax, -56(%rbp)
# param t7
# t8 = call readInt, 1
	movq	-56(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	readInt
	movq	%rax, -60(%rbp)
	addq	$8, %rsp
# y = t8
	movl	-60(%rbp), %eax
	movl	%eax, -8(%rbp)
# t9 = 99
	movb	$57, -61(%rbp)
# ch = t9
	movl	-61(%rbp), %eax
	movl	%eax, -62(%rbp)
# t10 = x + y
	movl	-4(%rbp), %eax
	movl	-8(%rbp), %edx
	addl	%edx, %eax
	movl	%eax, -70(%rbp)
# i = t10
	movl	-70(%rbp), %eax
	movl	%eax, i(%rip)
# param .LC2
# t11 = call printStr, 1
	movq	$.LC2, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -78(%rbp)
	addq	$4, %rsp
# param x
# t12 = call printInt, 1
	movq	-4(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -86(%rbp)
	addq	$4, %rsp
# param .LC3
# t13 = call printStr, 1
	movq	$.LC3, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -94(%rbp)
	addq	$4, %rsp
# param y
# t14 = call printInt, 1
	movq	-8(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -98(%rbp)
	addq	$4, %rsp
# param .LC4
# t15 = call printStr, 1
	movq	$.LC4, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -106(%rbp)
	addq	$4, %rsp
# param i
# t16 = call printInt, 1
	movq	i(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -110(%rbp)
	addq	$4, %rsp
# param .LC5
# t17 = call printStr, 1
	movq	$.LC5, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -118(%rbp)
	addq	$4, %rsp
# t18 = x - y
	movl	-4(%rbp), %edx
	movl	-8(%rbp), %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, -126(%rbp)
# j = t18
	movl	-126(%rbp), %eax
	movl	%eax, j(%rip)
# param .LC6
# t19 = call printStr, 1
	movq	$.LC6, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -134(%rbp)
	addq	$4, %rsp
# param x
# t20 = call printInt, 1
	movq	-4(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -138(%rbp)
	addq	$4, %rsp
# param .LC7
# t21 = call printStr, 1
	movq	$.LC7, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -146(%rbp)
	addq	$4, %rsp
# param y
# t22 = call printInt, 1
	movq	-8(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -150(%rbp)
	addq	$4, %rsp
# param .LC8
# t23 = call printStr, 1
	movq	$.LC8, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -158(%rbp)
	addq	$4, %rsp
# param j
# t24 = call printInt, 1
	movq	j(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -162(%rbp)
	addq	$4, %rsp
# param .LC9
# t25 = call printStr, 1
	movq	$.LC9, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -170(%rbp)
	addq	$4, %rsp
# t26 = x * y
	movl	-4(%rbp), %eax
	imull	-8(%rbp), %eax
	movl	%eax, -178(%rbp)
# k = t26
	movl	-178(%rbp), %eax
	movl	%eax, k(%rip)
# param .LC10
# t27 = call printStr, 1
	movq	$.LC10, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -186(%rbp)
	addq	$4, %rsp
# param x
# t28 = call printInt, 1
	movq	-4(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -190(%rbp)
	addq	$4, %rsp
# param .LC11
# t29 = call printStr, 1
	movq	$.LC11, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -198(%rbp)
	addq	$4, %rsp
# param y
# t30 = call printInt, 1
	movq	-8(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -202(%rbp)
	addq	$4, %rsp
# param .LC12
# t31 = call printStr, 1
	movq	$.LC12, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -210(%rbp)
	addq	$4, %rsp
# param k
# t32 = call printInt, 1
	movq	k(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -214(%rbp)
	addq	$4, %rsp
# param .LC13
# t33 = call printStr, 1
	movq	$.LC13, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -222(%rbp)
	addq	$4, %rsp
# t34 = x / y
	movl	-4(%rbp), %eax
	cltd
	idivl	-8(%rbp)
	movl	%eax, -230(%rbp)
# l = t34
	movl	-230(%rbp), %eax
	movl	%eax, l(%rip)
# param .LC14
# t35 = call printStr, 1
	movq	$.LC14, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -238(%rbp)
	addq	$4, %rsp
# param x
# t36 = call printInt, 1
	movq	-4(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -242(%rbp)
	addq	$4, %rsp
# param .LC15
# t37 = call printStr, 1
	movq	$.LC15, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -250(%rbp)
	addq	$4, %rsp
# param y
# t38 = call printInt, 1
	movq	-8(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -254(%rbp)
	addq	$4, %rsp
# param .LC16
# t39 = call printStr, 1
	movq	$.LC16, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -262(%rbp)
	addq	$4, %rsp
# param l
# t40 = call printInt, 1
	movq	l(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -266(%rbp)
	addq	$4, %rsp
# param .LC17
# t41 = call printStr, 1
	movq	$.LC17, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -274(%rbp)
	addq	$4, %rsp
# t42 = x % y
	movl	-4(%rbp), %eax
	cltd
	idivl	-8(%rbp)
	movl	%edx, -282(%rbp)
# m = t42
	movl	-282(%rbp), %eax
	movl	%eax, m(%rip)
# param .LC18
# t43 = call printStr, 1
	movq	$.LC18, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -290(%rbp)
	addq	$4, %rsp
# param x
# t44 = call printInt, 1
	movq	-4(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -294(%rbp)
	addq	$4, %rsp
# param .LC19
# t45 = call printStr, 1
	movq	$.LC19, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -302(%rbp)
	addq	$4, %rsp
# param y
# t46 = call printInt, 1
	movq	-8(%rbp), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -306(%rbp)
	addq	$4, %rsp
# param .LC20
# t47 = call printStr, 1
	movq	$.LC20, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -314(%rbp)
	addq	$4, %rsp
# param m
# t48 = call printInt, 1
	movq	m(%rip), %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printInt
	movq	%rax, -318(%rbp)
	addq	$4, %rsp
# param .LC21
# t49 = call printStr, 1
	movq	$.LC21, %rax
	pushq	%rax
	movq	%rax, %rdi
	call	printStr
	movq	%rax, -326(%rbp)
	addq	$4, %rsp
# t50 = 0
	movl	$0, -330(%rbp)
# return t50
	movq	-330(%rbp), %rax
	leave
	ret
# function main ends
	leave
	ret
	.size	main, .-main
