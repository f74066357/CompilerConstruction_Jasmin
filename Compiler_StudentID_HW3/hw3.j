.source hw3.j
.class public Main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
ldc 0
istore 0
ldc 999
istore 1
L_for_begin_0 :
iload 1
ldc 1
istore 1
L_for_begin_1 :
iload 1
ldc 9
isub
ifle L_cmp_0
iconst_0
goto L_cmp_1
L_cmp_0 :
iconst_1
L_cmp_1 :
goto pre_1
post_1:
iload 1
iload 1
ldc 1
iadd
istore 1
goto L_for_begin_1
pre_1:
ifeq L_for_exit_1
L_for_begin_2 :
iload 0
ldc 1
istore 0
L_for_begin_3 :
iload 0
ldc 9
isub
ifle L_cmp_2
iconst_0
goto L_cmp_3
L_cmp_2 :
iconst_1
L_cmp_3 :
goto pre_3
post_3:
iload 0
iload 0
ldc 1
iadd
istore 0
goto L_for_begin_3
pre_3:
ifeq L_for_exit_3
iload 1
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "*"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
iload 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "="
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
iload 1
iload 0
imul
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(I)V
ldc "\t"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
goto post_3
L_for_exit_3 :
ldc "\n"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap
invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V
goto post_1
L_for_exit_1 :
   return
.end method