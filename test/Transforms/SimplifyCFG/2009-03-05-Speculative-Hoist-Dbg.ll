; RUN: opt < %s -simplifycfg -S | grep select
        %llvm.dbg.anchor.type = type { i32, i32 }
        %llvm.dbg.compile_unit.type = type { i32, { }*, i32, i8*, i8*, i8*, i1, i1, i8* }

@llvm.dbg.compile_units = linkonce constant %llvm.dbg.anchor.type { i32 458752, i32 17 }, section "llvm.metadata"		; 

@.str = internal constant [4 x i8] c"a.c\00", section "llvm.metadata"		; <[4 x i8]*> [#uses=1]
@.str1 = internal constant [6 x i8] c"/tmp/\00", section "llvm.metadata"	; <[6 x i8]*> [#uses=1]
@.str2 = internal constant [55 x i8] c"4.2.1 (Based on Apple Inc. build 5636) (LLVM build 00)\00", section "llvm.metadata"		; <[55 x i8]*> [#uses=1]
@llvm.dbg.compile_unit = internal constant %llvm.dbg.compile_unit.type { i32 458769, { }* bitcast (%llvm.dbg.anchor.type* @llvm.dbg.compile_units to { }*), i32 1, i8* getelementptr ([4 x i8]* @.str, i32 0, i32 0), i8* getelementptr ([6 x i8]* @.str1, i32 0, i32 0), i8* getelementptr ([55 x i8]* @.str2, i32 0, i32 0), i1 true, i1 false, i8* null }, section "llvm.metadata"		; <%llvm.dbg.compile_unit.type*> [#uses=1]

declare void @llvm.dbg.stoppoint(i32, i32, { }*) nounwind

external global <{ i8 }>		; <<{ i8 }>*>:0 [#uses=0]
@__dso_handle = external global i8*		; <i8**> [#uses=0]
@_ZSt3cin = external global { i32 (...)**, i32, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, \3 }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }		; <{ i32 (...)**, i32, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, \3 }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
@_ZSt4cout = external global { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
external constant [2 x i8]		; <[2 x i8]*>:1 [#uses=1]
@llvm.global_ctors = external global [1 x { i32, void ()* }]		; <[1 x { i32, void ()* }]*> [#uses=0]

define i32 @main(i32, i8**) {
; <label>:2
	%3 = alloca [4096 x i8], align 1		; <[4096 x i8]*> [#uses=1]
	%4 = call { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* @_ZNKSt9basic_iosIcSt11char_traitsIcEE5rdbufEv({ { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* }* getelementptr ({ i32 (...)**, i32, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, \3 }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZSt3cin, i32 0, i32 2))		; <{ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*> [#uses=1]
	%5 = getelementptr [4096 x i8]* %3, i32 0, i32 0		; <i8*> [#uses=1]
	%6 = call { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* @_ZNSt15basic_streambufIcSt11char_traitsIcEE9pubsetbufEPci({ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* %4, i8* %5, i32 4096)		; <{ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*> [#uses=0]
	%7 = call { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* @_ZNKSt9basic_iosIcSt11char_traitsIcEE5rdbufEv({ { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* }* getelementptr ({ i32 (...)**, i32, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, \3 }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZSt3cin, i32 0, i32 2))		; <{ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*> [#uses=1]
	br label %25

; <label>:8		; preds = %25
	%9 = trunc i32 %26 to i8		; <i8> [#uses=4]
	%10 = add i32 %.02, 1		; <i32> [#uses=3]
	%11 = icmp eq i8 %9, 10		; <i1> [#uses=1]
	br i1 %11, label %12, label %14

; <label>:12		; preds = %8
	%13 = add i32 %.1, 1		; <i32> [#uses=1]
	br label %14

; <label>:14		; preds = %12, %8
	%.0 = phi i32 [ %.1, %8 ], [ %13, %12 ]		; <i32> [#uses=3]
	%15 = icmp eq i8 %9, 32		; <i1> [#uses=1]
	br i1 %15, label %20, label %16

; <label>:16		; preds = %14
	%17 = icmp eq i8 %9, 10		; <i1> [#uses=1]
	br i1 %17, label %20, label %18

; <label>:18		; preds = %16
	%19 = icmp eq i8 %9, 9		; <i1> [#uses=1]
	br i1 %19, label %20, label %21

; <label>:20		; preds = %18, %16, %14
	br label %25

; <label>:21		; preds = %18
	%22 = icmp eq i32 %.03, 0		; <i1> [#uses=1]
	br i1 %22, label %23, label %25

; <label>:23		; preds = %21
        call void @llvm.dbg.stoppoint(i32 5, i32 0, { }* bitcast (%llvm.dbg.compile_unit.type* @llvm.dbg.compile_unit to { }*))
	%24 = add i32 %.01, 1		; <i32> [#uses=1]
	br label %25

; <label>:25		; preds = %23, %21, %20, %2
	%.03 = phi i32 [ 0, %2 ], [ %.03, %21 ], [ 1, %23 ], [ 0, %20 ]		; <i32> [#uses=2]
	%.02 = phi i32 [ 0, %2 ], [ %10, %21 ], [ %10, %23 ], [ %10, %20 ]		; <i32> [#uses=2]
	%.01 = phi i32 [ 0, %2 ], [ %.01, %21 ], [ %24, %23 ], [ %.01, %20 ]		; <i32> [#uses=4]
	%.1 = phi i32 [ 0, %2 ], [ %.0, %21 ], [ %.0, %23 ], [ %.0, %20 ]		; <i32> [#uses=3]
	%26 = call i32 @_ZNSt15basic_streambufIcSt11char_traitsIcEE6sbumpcEv({ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* %7)		; <i32> [#uses=2]
	%27 = icmp eq i32 %26, -1		; <i1> [#uses=1]
	br i1 %27, label %28, label %8

; <label>:28		; preds = %25
	%29 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEi({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZSt4cout, i32 %.1)		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
	%30 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* %29, i8* getelementptr ([2 x i8]* @1, i32 0, i32 0))		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
	%31 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEi({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* %30, i32 %.01)		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
	%32 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* %31, i8* getelementptr ([2 x i8]* @1, i32 0, i32 0))		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
	%33 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEi({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* %32, i32 %.02)		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=1]
	%34 = call { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEPFRSoS_E({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* %33, { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* ({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*)* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_)		; <{ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*> [#uses=0]
	ret i32 0
}

declare void @""() section "__TEXT,__StaticInit,regular,pure_instructions"

declare fastcc void @""() section "__TEXT,__StaticInit,regular,pure_instructions"

declare void @_ZNSt8ios_base4InitC1Ev(<{ i8 }>*)

declare i32 @__cxa_atexit(void (i8*)*, i8*, i8*) nounwind

declare void @""(i8*)

declare void @_ZNSt8ios_base4InitD1Ev(<{ i8 }>*)

declare { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* @_ZNKSt9basic_iosIcSt11char_traitsIcEE5rdbufEv({ { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* }*)

declare { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }* @_ZNSt15basic_streambufIcSt11char_traitsIcEE9pubsetbufEPci({ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, i8*, i32)

declare i32 @_ZNSt15basic_streambufIcSt11char_traitsIcEE6sbumpcEv({ i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*)

declare { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEi({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, i32)

declare { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, i8*)

declare { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZNSolsEPFRSoS_E({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*, { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* ({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*)*)

declare { i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_({ i32 (...)**, { { i32 (...)**, i32, i32, i32, i32, i32, { \2, void (i32, \6*, i32)*, i32, i32 }*, { i8*, i32 }, [8 x { i8*, i32 }], i32, { i8*, i32 }*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }, \3*, i8, i8, { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, { { i32, { i32 (...)**, i32 }**, i32, { i32 (...)**, i32 }**, i8** }* } }*, { { i32 (...)**, i32 }, i32*, i8, i32*, i32*, i32*, i8, [256 x i8], [256 x i8], i8 }*, { { i32 (...)**, i32 } }*, { { i32 (...)**, i32 } }* } }*)
