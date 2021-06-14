
/home/zp/develop/BL702/bl702_debugger/out/usb/usb2uartjtag/usb2uartjtag_main.elf:     file format elf32-littleriscv


Disassembly of section .text:

23000000 <__text_code_start__>:
     * it's not valid to obtain the address of any symbol without GP
     * configured.  The C environment might go ahead and do this again, but
     * that's safe as it's a fixed register. */
.option push
.option norelax
    la gp, __global_pointer$
23000000:	1f018197          	auipc	gp,0x1f018
23000004:	00018193          	mv	gp,gp
.option pop

    /* Disable global interrupt */
    /*clear_csr(mstatus, MSTATUS_MIE);*/
    csrci mstatus,8
23000008:	30047073          	csrci	mstatus,8

    /* Set up a simple trap vector to catch anything that goes wrong early in
     * the boot process. */
    la t0, Trap_Handler_Stub
2300000c:	00003297          	auipc	t0,0x3
23000010:	8f428293          	addi	t0,t0,-1804 # 23002900 <Trap_Handler_Stub>
    /* enable CLIC Vectored mode */
    ori	t0,t0,3
23000014:	0032e293          	ori	t0,t0,3
    csrw mtvec, t0
23000018:	30529073          	csrw	mtvec,t0
    /* enable chicken bit if core is bullet series*/
    la t0, __metal_chicken_bit
2300001c:	00000293          	li	t0,0
    beqz t0, 1f
23000020:	00028463          	beqz	t0,23000028 <__text_code_start__+0x28>
    csrwi 0x7C1, 0
23000024:	7c105073          	csrwi	mhcr,0
     * C, so here we set up a C environment.  First we set up a stack pointer,
     * which is left as a weak reference in order to allow initialization
     * routines that do not need a stack to be set up to transparently be
     * called. */
    .weak __StackTop
    la sp, __StackTop
23000028:	1f020117          	auipc	sp,0x1f020
2300002c:	fd810113          	addi	sp,sp,-40 # 42020000 <__StackTop>
    
    /* Intial the mtvt, MUST BE 64 bytes aligned*/
    .weak __Vectors
    la t0, __Vectors
23000030:	00000297          	auipc	t0,0x0
23000034:	05028293          	addi	t0,t0,80 # 23000080 <__Vectors>
    csrw mtvt, t0
23000038:	30729073          	csrw	mtvt,t0
     * just skip over the call entirely.   Note that __metal_initialize isn't
     * actually a full C function, as it doesn't end up with the .bss or .data
     * segments having been initialized.  This is done to avoid putting a
     * burden on systems that can be initialized without having a C environment
     * set up. */
    call SystemInit
2300003c:	17d020ef          	jal	ra,230029b8 <SystemInit>

    /* start load code to itcm like. */
    call start_load
23000040:	7b2020ef          	jal	ra,230027f2 <start_load>

    /* At this point we can enter the C runtime's startup file.  The arguments
     * to this function are designed to match those provided to the SEE, just
     * so we don't have to write another ABI. */
    csrr a0, mhartid
23000044:	f1402573          	csrr	a0,mhartid
    li a1, 0
23000048:	4581                	li	a1,0
    li a2, 0
2300004a:	4601                	li	a2,0
    call main
2300004c:	295000ef          	jal	ra,23000ae0 <main>

    /* If we've made it back here then there's probably something wrong.  We
     * allow the METAL to register a handler here. */
    .weak __metal_after_main
    la ra, __metal_after_main
23000050:	dd000097          	auipc	ra,0xdd000
23000054:	fb008093          	addi	ra,ra,-80 # 0 <__metal_chicken_bit>
    beqz ra, 1f
23000058:	00008363          	beqz	ra,2300005e <__text_code_start__+0x5e>
    jalr ra
2300005c:	9082                	jalr	ra
1:

    /* If that handler returns then there's not a whole lot we can do.  Just
     * try to make some noise. */
     la t0, 1f
2300005e:	00000297          	auipc	t0,0x0
23000062:	00c28293          	addi	t0,t0,12 # 2300006a <__text_code_start__+0x6a>
     csrw mtvec, t0
23000066:	30529073          	csrw	mtvec,t0
1:
     lw t1, 0(x0)
2300006a:	00002303          	lw	t1,0(zero) # 0 <__metal_chicken_bit>
     j 1b
2300006e:	bff5                	j	2300006a <__text_code_start__+0x6a>
	...

23000080 <__Vectors>:
	...
2300008c:	28b0 2300 0000 0000 0000 0000 0000 0000     .(.#............
2300009c:	28b0 2300 0001 0000 0000 0000 0100 0000     .(.#............
230000ac:	28b0 2300 28b0 2300 0000 0000 0000 0000     .(.#.(.#........
230000bc:	0000 0000 28b0 2300 28b0 2300 28b0 2300     .....(.#.(.#.(.#
230000cc:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
230000dc:	0000 0000 28b0 2300 28b0 2300 28b0 2300     .....(.#.(.#.(.#
230000ec:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
230000fc:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
2300010c:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
2300011c:	28b0 2300 0000 0000 28b0 2300 28b0 2300     .(.#.....(.#.(.#
2300012c:	28b0 2300 0000 0000 28b0 2300 28b0 2300     .(.#.....(.#.(.#
2300013c:	0000 0000 28b0 2300 0000 0000 28b0 2300     .....(.#.....(.#
2300014c:	0000 0000 28b0 2300 28b0 2300 28b0 2300     .....(.#.(.#.(.#
2300015c:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
2300016c:	0000 0000 28b0 2300 28b0 2300 0000 0000     .....(.#.(.#....
2300017c:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
2300018c:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
2300019c:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
230001ac:	28b0 2300 28b0 2300 28b0 2300 28b0 2300     .(.#.(.#.(.#.(.#
230001bc:	28b0 2300 0000 0000                         .(.#....

230001c4 <__ctzsi2>:
230001c4:	40a007b3          	neg	a5,a0
230001c8:	8d7d                	and	a0,a0,a5
230001ca:	67c1                	lui	a5,0x10
230001cc:	02f57363          	bgeu	a0,a5,230001f2 <__ctzsi2+0x2e>
230001d0:	0ff00793          	li	a5,255
230001d4:	00a7b7b3          	sltu	a5,a5,a0
230001d8:	078e                	slli	a5,a5,0x3
230001da:	00f55533          	srl	a0,a0,a5
230001de:	00006717          	auipc	a4,0x6
230001e2:	50270713          	addi	a4,a4,1282 # 230066e0 <__clz_tab>
230001e6:	953a                	add	a0,a0,a4
230001e8:	00054503          	lbu	a0,0(a0)
230001ec:	17fd                	addi	a5,a5,-1
230001ee:	953e                	add	a0,a0,a5
230001f0:	8082                	ret
230001f2:	01000737          	lui	a4,0x1000
230001f6:	47c1                	li	a5,16
230001f8:	fee561e3          	bltu	a0,a4,230001da <__ctzsi2+0x16>
230001fc:	47e1                	li	a5,24
230001fe:	bff1                	j	230001da <__ctzsi2+0x16>

23000200 <__udivdi3>:
23000200:	87ae                	mv	a5,a1
23000202:	8832                	mv	a6,a2
23000204:	8736                	mv	a4,a3
23000206:	832a                	mv	t1,a0
23000208:	20069663          	bnez	a3,23000414 <__udivdi3+0x214>
2300020c:	00006897          	auipc	a7,0x6
23000210:	4d488893          	addi	a7,a7,1236 # 230066e0 <__clz_tab>
23000214:	0ac5fe63          	bgeu	a1,a2,230002d0 <__udivdi3+0xd0>
23000218:	6741                	lui	a4,0x10
2300021a:	0ae67463          	bgeu	a2,a4,230002c2 <__udivdi3+0xc2>
2300021e:	0ff00713          	li	a4,255
23000222:	00c73733          	sltu	a4,a4,a2
23000226:	070e                	slli	a4,a4,0x3
23000228:	00e656b3          	srl	a3,a2,a4
2300022c:	98b6                	add	a7,a7,a3
2300022e:	0008c683          	lbu	a3,0(a7)
23000232:	9736                	add	a4,a4,a3
23000234:	02000693          	li	a3,32
23000238:	8e99                	sub	a3,a3,a4
2300023a:	ca99                	beqz	a3,23000250 <__udivdi3+0x50>
2300023c:	00d797b3          	sll	a5,a5,a3
23000240:	00e55733          	srl	a4,a0,a4
23000244:	00d61833          	sll	a6,a2,a3
23000248:	00f765b3          	or	a1,a4,a5
2300024c:	00d51333          	sll	t1,a0,a3
23000250:	01085513          	srli	a0,a6,0x10
23000254:	02a5f733          	remu	a4,a1,a0
23000258:	01081613          	slli	a2,a6,0x10
2300025c:	8241                	srli	a2,a2,0x10
2300025e:	01035693          	srli	a3,t1,0x10
23000262:	02a5d5b3          	divu	a1,a1,a0
23000266:	0742                	slli	a4,a4,0x10
23000268:	8ed9                	or	a3,a3,a4
2300026a:	02b607b3          	mul	a5,a2,a1
2300026e:	872e                	mv	a4,a1
23000270:	00f6fc63          	bgeu	a3,a5,23000288 <__udivdi3+0x88>
23000274:	96c2                	add	a3,a3,a6
23000276:	fff58713          	addi	a4,a1,-1
2300027a:	0106e763          	bltu	a3,a6,23000288 <__udivdi3+0x88>
2300027e:	00f6f563          	bgeu	a3,a5,23000288 <__udivdi3+0x88>
23000282:	ffe58713          	addi	a4,a1,-2
23000286:	96c2                	add	a3,a3,a6
23000288:	8e9d                	sub	a3,a3,a5
2300028a:	02a6f7b3          	remu	a5,a3,a0
2300028e:	0342                	slli	t1,t1,0x10
23000290:	01035313          	srli	t1,t1,0x10
23000294:	02a6d6b3          	divu	a3,a3,a0
23000298:	07c2                	slli	a5,a5,0x10
2300029a:	0067e333          	or	t1,a5,t1
2300029e:	02d605b3          	mul	a1,a2,a3
230002a2:	8536                	mv	a0,a3
230002a4:	00b37b63          	bgeu	t1,a1,230002ba <__udivdi3+0xba>
230002a8:	9342                	add	t1,t1,a6
230002aa:	fff68513          	addi	a0,a3,-1
230002ae:	01036663          	bltu	t1,a6,230002ba <__udivdi3+0xba>
230002b2:	00b37463          	bgeu	t1,a1,230002ba <__udivdi3+0xba>
230002b6:	ffe68513          	addi	a0,a3,-2
230002ba:	0742                	slli	a4,a4,0x10
230002bc:	8f49                	or	a4,a4,a0
230002be:	4581                	li	a1,0
230002c0:	a84d                	j	23000372 <__udivdi3+0x172>
230002c2:	010006b7          	lui	a3,0x1000
230002c6:	4741                	li	a4,16
230002c8:	f6d660e3          	bltu	a2,a3,23000228 <__udivdi3+0x28>
230002cc:	4761                	li	a4,24
230002ce:	bfa9                	j	23000228 <__udivdi3+0x28>
230002d0:	e601                	bnez	a2,230002d8 <__udivdi3+0xd8>
230002d2:	4685                	li	a3,1
230002d4:	02c6d833          	divu	a6,a3,a2
230002d8:	66c1                	lui	a3,0x10
230002da:	08d87e63          	bgeu	a6,a3,23000376 <__udivdi3+0x176>
230002de:	0ff00693          	li	a3,255
230002e2:	0106f363          	bgeu	a3,a6,230002e8 <__udivdi3+0xe8>
230002e6:	4721                	li	a4,8
230002e8:	00e856b3          	srl	a3,a6,a4
230002ec:	98b6                	add	a7,a7,a3
230002ee:	0008c683          	lbu	a3,0(a7)
230002f2:	96ba                	add	a3,a3,a4
230002f4:	02000713          	li	a4,32
230002f8:	8f15                	sub	a4,a4,a3
230002fa:	e749                	bnez	a4,23000384 <__udivdi3+0x184>
230002fc:	410787b3          	sub	a5,a5,a6
23000300:	4585                	li	a1,1
23000302:	01085613          	srli	a2,a6,0x10
23000306:	01081893          	slli	a7,a6,0x10
2300030a:	0108d893          	srli	a7,a7,0x10
2300030e:	01035693          	srli	a3,t1,0x10
23000312:	02c7f733          	remu	a4,a5,a2
23000316:	02c7d7b3          	divu	a5,a5,a2
2300031a:	0742                	slli	a4,a4,0x10
2300031c:	8ed9                	or	a3,a3,a4
2300031e:	02f88533          	mul	a0,a7,a5
23000322:	873e                	mv	a4,a5
23000324:	00a6fc63          	bgeu	a3,a0,2300033c <__udivdi3+0x13c>
23000328:	96c2                	add	a3,a3,a6
2300032a:	fff78713          	addi	a4,a5,-1 # ffff <HeapSize+0xefff>
2300032e:	0106e763          	bltu	a3,a6,2300033c <__udivdi3+0x13c>
23000332:	00a6f563          	bgeu	a3,a0,2300033c <__udivdi3+0x13c>
23000336:	ffe78713          	addi	a4,a5,-2
2300033a:	96c2                	add	a3,a3,a6
2300033c:	8e89                	sub	a3,a3,a0
2300033e:	02c6f7b3          	remu	a5,a3,a2
23000342:	0342                	slli	t1,t1,0x10
23000344:	01035313          	srli	t1,t1,0x10
23000348:	02c6d6b3          	divu	a3,a3,a2
2300034c:	07c2                	slli	a5,a5,0x10
2300034e:	0067e333          	or	t1,a5,t1
23000352:	02d888b3          	mul	a7,a7,a3
23000356:	8536                	mv	a0,a3
23000358:	01137b63          	bgeu	t1,a7,2300036e <__udivdi3+0x16e>
2300035c:	9342                	add	t1,t1,a6
2300035e:	fff68513          	addi	a0,a3,-1 # ffff <HeapSize+0xefff>
23000362:	01036663          	bltu	t1,a6,2300036e <__udivdi3+0x16e>
23000366:	01137463          	bgeu	t1,a7,2300036e <__udivdi3+0x16e>
2300036a:	ffe68513          	addi	a0,a3,-2
2300036e:	0742                	slli	a4,a4,0x10
23000370:	8f49                	or	a4,a4,a0
23000372:	853a                	mv	a0,a4
23000374:	8082                	ret
23000376:	010006b7          	lui	a3,0x1000
2300037a:	4741                	li	a4,16
2300037c:	f6d866e3          	bltu	a6,a3,230002e8 <__udivdi3+0xe8>
23000380:	4761                	li	a4,24
23000382:	b79d                	j	230002e8 <__udivdi3+0xe8>
23000384:	00e81833          	sll	a6,a6,a4
23000388:	00d7d5b3          	srl	a1,a5,a3
2300038c:	00e51333          	sll	t1,a0,a4
23000390:	00d556b3          	srl	a3,a0,a3
23000394:	01085513          	srli	a0,a6,0x10
23000398:	00e797b3          	sll	a5,a5,a4
2300039c:	02a5f733          	remu	a4,a1,a0
230003a0:	00f6e8b3          	or	a7,a3,a5
230003a4:	01081793          	slli	a5,a6,0x10
230003a8:	83c1                	srli	a5,a5,0x10
230003aa:	0108d613          	srli	a2,a7,0x10
230003ae:	02a5d5b3          	divu	a1,a1,a0
230003b2:	0742                	slli	a4,a4,0x10
230003b4:	8f51                	or	a4,a4,a2
230003b6:	02b786b3          	mul	a3,a5,a1
230003ba:	862e                	mv	a2,a1
230003bc:	00d77c63          	bgeu	a4,a3,230003d4 <__udivdi3+0x1d4>
230003c0:	9742                	add	a4,a4,a6
230003c2:	fff58613          	addi	a2,a1,-1
230003c6:	01076763          	bltu	a4,a6,230003d4 <__udivdi3+0x1d4>
230003ca:	00d77563          	bgeu	a4,a3,230003d4 <__udivdi3+0x1d4>
230003ce:	ffe58613          	addi	a2,a1,-2
230003d2:	9742                	add	a4,a4,a6
230003d4:	40d706b3          	sub	a3,a4,a3
230003d8:	02a6f733          	remu	a4,a3,a0
230003dc:	08c2                	slli	a7,a7,0x10
230003de:	0108d893          	srli	a7,a7,0x10
230003e2:	02a6d6b3          	divu	a3,a3,a0
230003e6:	0742                	slli	a4,a4,0x10
230003e8:	02d785b3          	mul	a1,a5,a3
230003ec:	011767b3          	or	a5,a4,a7
230003f0:	8736                	mv	a4,a3
230003f2:	00b7fc63          	bgeu	a5,a1,2300040a <__udivdi3+0x20a>
230003f6:	97c2                	add	a5,a5,a6
230003f8:	fff68713          	addi	a4,a3,-1 # ffffff <HeapSize+0xffefff>
230003fc:	0107e763          	bltu	a5,a6,2300040a <__udivdi3+0x20a>
23000400:	00b7f563          	bgeu	a5,a1,2300040a <__udivdi3+0x20a>
23000404:	ffe68713          	addi	a4,a3,-2
23000408:	97c2                	add	a5,a5,a6
2300040a:	8f8d                	sub	a5,a5,a1
2300040c:	01061593          	slli	a1,a2,0x10
23000410:	8dd9                	or	a1,a1,a4
23000412:	bdc5                	j	23000302 <__udivdi3+0x102>
23000414:	14d5e263          	bltu	a1,a3,23000558 <__udivdi3+0x358>
23000418:	6741                	lui	a4,0x10
2300041a:	02e6fe63          	bgeu	a3,a4,23000456 <__udivdi3+0x256>
2300041e:	0ff00813          	li	a6,255
23000422:	00d83733          	sltu	a4,a6,a3
23000426:	070e                	slli	a4,a4,0x3
23000428:	00e6d833          	srl	a6,a3,a4
2300042c:	00006597          	auipc	a1,0x6
23000430:	2b458593          	addi	a1,a1,692 # 230066e0 <__clz_tab>
23000434:	95c2                	add	a1,a1,a6
23000436:	0005c803          	lbu	a6,0(a1)
2300043a:	02000593          	li	a1,32
2300043e:	983a                	add	a6,a6,a4
23000440:	410585b3          	sub	a1,a1,a6
23000444:	e185                	bnez	a1,23000464 <__udivdi3+0x264>
23000446:	4705                	li	a4,1
23000448:	f2f6e5e3          	bltu	a3,a5,23000372 <__udivdi3+0x172>
2300044c:	00c53533          	sltu	a0,a0,a2
23000450:	00154713          	xori	a4,a0,1
23000454:	bf39                	j	23000372 <__udivdi3+0x172>
23000456:	010005b7          	lui	a1,0x1000
2300045a:	4741                	li	a4,16
2300045c:	fcb6e6e3          	bltu	a3,a1,23000428 <__udivdi3+0x228>
23000460:	4761                	li	a4,24
23000462:	b7d9                	j	23000428 <__udivdi3+0x228>
23000464:	01065733          	srl	a4,a2,a6
23000468:	00b696b3          	sll	a3,a3,a1
2300046c:	8ed9                	or	a3,a3,a4
2300046e:	0106de93          	srli	t4,a3,0x10
23000472:	0107d733          	srl	a4,a5,a6
23000476:	03d778b3          	remu	a7,a4,t4
2300047a:	00b797b3          	sll	a5,a5,a1
2300047e:	01055833          	srl	a6,a0,a6
23000482:	00f86333          	or	t1,a6,a5
23000486:	01069793          	slli	a5,a3,0x10
2300048a:	83c1                	srli	a5,a5,0x10
2300048c:	01035813          	srli	a6,t1,0x10
23000490:	00b61633          	sll	a2,a2,a1
23000494:	03d75733          	divu	a4,a4,t4
23000498:	08c2                	slli	a7,a7,0x10
2300049a:	0108e833          	or	a6,a7,a6
2300049e:	02e78f33          	mul	t5,a5,a4
230004a2:	8e3a                	mv	t3,a4
230004a4:	01e87c63          	bgeu	a6,t5,230004bc <__udivdi3+0x2bc>
230004a8:	9836                	add	a6,a6,a3
230004aa:	fff70e13          	addi	t3,a4,-1 # ffff <HeapSize+0xefff>
230004ae:	00d86763          	bltu	a6,a3,230004bc <__udivdi3+0x2bc>
230004b2:	01e87563          	bgeu	a6,t5,230004bc <__udivdi3+0x2bc>
230004b6:	ffe70e13          	addi	t3,a4,-2
230004ba:	9836                	add	a6,a6,a3
230004bc:	41e80833          	sub	a6,a6,t5
230004c0:	03d878b3          	remu	a7,a6,t4
230004c4:	03d85833          	divu	a6,a6,t4
230004c8:	08c2                	slli	a7,a7,0x10
230004ca:	03078eb3          	mul	t4,a5,a6
230004ce:	01031793          	slli	a5,t1,0x10
230004d2:	83c1                	srli	a5,a5,0x10
230004d4:	00f8e7b3          	or	a5,a7,a5
230004d8:	8742                	mv	a4,a6
230004da:	01d7fc63          	bgeu	a5,t4,230004f2 <__udivdi3+0x2f2>
230004de:	97b6                	add	a5,a5,a3
230004e0:	fff80713          	addi	a4,a6,-1
230004e4:	00d7e763          	bltu	a5,a3,230004f2 <__udivdi3+0x2f2>
230004e8:	01d7f563          	bgeu	a5,t4,230004f2 <__udivdi3+0x2f2>
230004ec:	ffe80713          	addi	a4,a6,-2
230004f0:	97b6                	add	a5,a5,a3
230004f2:	0e42                	slli	t3,t3,0x10
230004f4:	41d787b3          	sub	a5,a5,t4
230004f8:	6ec1                	lui	t4,0x10
230004fa:	00ee6733          	or	a4,t3,a4
230004fe:	fffe8813          	addi	a6,t4,-1 # ffff <HeapSize+0xefff>
23000502:	01077333          	and	t1,a4,a6
23000506:	01075893          	srli	a7,a4,0x10
2300050a:	01067833          	and	a6,a2,a6
2300050e:	8241                	srli	a2,a2,0x10
23000510:	03030e33          	mul	t3,t1,a6
23000514:	03088833          	mul	a6,a7,a6
23000518:	010e5693          	srli	a3,t3,0x10
2300051c:	02c30333          	mul	t1,t1,a2
23000520:	9342                	add	t1,t1,a6
23000522:	969a                	add	a3,a3,t1
23000524:	02c888b3          	mul	a7,a7,a2
23000528:	0106f363          	bgeu	a3,a6,2300052e <__udivdi3+0x32e>
2300052c:	98f6                	add	a7,a7,t4
2300052e:	0106d613          	srli	a2,a3,0x10
23000532:	98b2                	add	a7,a7,a2
23000534:	0317e063          	bltu	a5,a7,23000554 <__udivdi3+0x354>
23000538:	d91793e3          	bne	a5,a7,230002be <__udivdi3+0xbe>
2300053c:	67c1                	lui	a5,0x10
2300053e:	17fd                	addi	a5,a5,-1
23000540:	8efd                	and	a3,a3,a5
23000542:	06c2                	slli	a3,a3,0x10
23000544:	00fe7e33          	and	t3,t3,a5
23000548:	00b51533          	sll	a0,a0,a1
2300054c:	96f2                	add	a3,a3,t3
2300054e:	4581                	li	a1,0
23000550:	e2d571e3          	bgeu	a0,a3,23000372 <__udivdi3+0x172>
23000554:	177d                	addi	a4,a4,-1
23000556:	b3a5                	j	230002be <__udivdi3+0xbe>
23000558:	4581                	li	a1,0
2300055a:	4701                	li	a4,0
2300055c:	bd19                	j	23000372 <__udivdi3+0x172>

2300055e <__umoddi3>:
2300055e:	88b2                	mv	a7,a2
23000560:	8736                	mv	a4,a3
23000562:	87aa                	mv	a5,a0
23000564:	882e                	mv	a6,a1
23000566:	1c069863          	bnez	a3,23000736 <__umoddi3+0x1d8>
2300056a:	00006697          	auipc	a3,0x6
2300056e:	17668693          	addi	a3,a3,374 # 230066e0 <__clz_tab>
23000572:	0ac5f863          	bgeu	a1,a2,23000622 <__umoddi3+0xc4>
23000576:	6341                	lui	t1,0x10
23000578:	08667e63          	bgeu	a2,t1,23000614 <__umoddi3+0xb6>
2300057c:	0ff00313          	li	t1,255
23000580:	00c37363          	bgeu	t1,a2,23000586 <__umoddi3+0x28>
23000584:	4721                	li	a4,8
23000586:	00e65333          	srl	t1,a2,a4
2300058a:	969a                	add	a3,a3,t1
2300058c:	0006ce03          	lbu	t3,0(a3)
23000590:	02000313          	li	t1,32
23000594:	9e3a                	add	t3,t3,a4
23000596:	41c30333          	sub	t1,t1,t3
2300059a:	00030c63          	beqz	t1,230005b2 <__umoddi3+0x54>
2300059e:	006595b3          	sll	a1,a1,t1
230005a2:	01c55e33          	srl	t3,a0,t3
230005a6:	006618b3          	sll	a7,a2,t1
230005aa:	00be6833          	or	a6,t3,a1
230005ae:	006517b3          	sll	a5,a0,t1
230005b2:	0108d613          	srli	a2,a7,0x10
230005b6:	02c87733          	remu	a4,a6,a2
230005ba:	01089513          	slli	a0,a7,0x10
230005be:	8141                	srli	a0,a0,0x10
230005c0:	0107d693          	srli	a3,a5,0x10
230005c4:	02c85833          	divu	a6,a6,a2
230005c8:	0742                	slli	a4,a4,0x10
230005ca:	8ed9                	or	a3,a3,a4
230005cc:	03050833          	mul	a6,a0,a6
230005d0:	0106f863          	bgeu	a3,a6,230005e0 <__umoddi3+0x82>
230005d4:	96c6                	add	a3,a3,a7
230005d6:	0116e563          	bltu	a3,a7,230005e0 <__umoddi3+0x82>
230005da:	0106f363          	bgeu	a3,a6,230005e0 <__umoddi3+0x82>
230005de:	96c6                	add	a3,a3,a7
230005e0:	410686b3          	sub	a3,a3,a6
230005e4:	02c6f733          	remu	a4,a3,a2
230005e8:	07c2                	slli	a5,a5,0x10
230005ea:	83c1                	srli	a5,a5,0x10
230005ec:	02c6d6b3          	divu	a3,a3,a2
230005f0:	02d506b3          	mul	a3,a0,a3
230005f4:	01071513          	slli	a0,a4,0x10
230005f8:	8fc9                	or	a5,a5,a0
230005fa:	00d7f863          	bgeu	a5,a3,2300060a <__umoddi3+0xac>
230005fe:	97c6                	add	a5,a5,a7
23000600:	0117e563          	bltu	a5,a7,2300060a <__umoddi3+0xac>
23000604:	00d7f363          	bgeu	a5,a3,2300060a <__umoddi3+0xac>
23000608:	97c6                	add	a5,a5,a7
2300060a:	8f95                	sub	a5,a5,a3
2300060c:	0067d533          	srl	a0,a5,t1
23000610:	4581                	li	a1,0
23000612:	8082                	ret
23000614:	01000337          	lui	t1,0x1000
23000618:	4741                	li	a4,16
2300061a:	f66666e3          	bltu	a2,t1,23000586 <__umoddi3+0x28>
2300061e:	4761                	li	a4,24
23000620:	b79d                	j	23000586 <__umoddi3+0x28>
23000622:	e601                	bnez	a2,2300062a <__umoddi3+0xcc>
23000624:	4605                	li	a2,1
23000626:	031658b3          	divu	a7,a2,a7
2300062a:	6641                	lui	a2,0x10
2300062c:	08c8f363          	bgeu	a7,a2,230006b2 <__umoddi3+0x154>
23000630:	0ff00613          	li	a2,255
23000634:	01167363          	bgeu	a2,a7,2300063a <__umoddi3+0xdc>
23000638:	4721                	li	a4,8
2300063a:	00e8d633          	srl	a2,a7,a4
2300063e:	96b2                	add	a3,a3,a2
23000640:	0006ce03          	lbu	t3,0(a3)
23000644:	02000313          	li	t1,32
23000648:	9e3a                	add	t3,t3,a4
2300064a:	41c30333          	sub	t1,t1,t3
2300064e:	06031963          	bnez	t1,230006c0 <__umoddi3+0x162>
23000652:	411585b3          	sub	a1,a1,a7
23000656:	0108d713          	srli	a4,a7,0x10
2300065a:	01089513          	slli	a0,a7,0x10
2300065e:	8141                	srli	a0,a0,0x10
23000660:	0107d613          	srli	a2,a5,0x10
23000664:	02e5f6b3          	remu	a3,a1,a4
23000668:	02e5d5b3          	divu	a1,a1,a4
2300066c:	06c2                	slli	a3,a3,0x10
2300066e:	8ed1                	or	a3,a3,a2
23000670:	02b505b3          	mul	a1,a0,a1
23000674:	00b6f863          	bgeu	a3,a1,23000684 <__umoddi3+0x126>
23000678:	96c6                	add	a3,a3,a7
2300067a:	0116e563          	bltu	a3,a7,23000684 <__umoddi3+0x126>
2300067e:	00b6f363          	bgeu	a3,a1,23000684 <__umoddi3+0x126>
23000682:	96c6                	add	a3,a3,a7
23000684:	40b685b3          	sub	a1,a3,a1
23000688:	02e5f6b3          	remu	a3,a1,a4
2300068c:	07c2                	slli	a5,a5,0x10
2300068e:	83c1                	srli	a5,a5,0x10
23000690:	02e5d5b3          	divu	a1,a1,a4
23000694:	02b505b3          	mul	a1,a0,a1
23000698:	01069513          	slli	a0,a3,0x10
2300069c:	8fc9                	or	a5,a5,a0
2300069e:	00b7f863          	bgeu	a5,a1,230006ae <__umoddi3+0x150>
230006a2:	97c6                	add	a5,a5,a7
230006a4:	0117e563          	bltu	a5,a7,230006ae <__umoddi3+0x150>
230006a8:	00b7f363          	bgeu	a5,a1,230006ae <__umoddi3+0x150>
230006ac:	97c6                	add	a5,a5,a7
230006ae:	8f8d                	sub	a5,a5,a1
230006b0:	bfb1                	j	2300060c <__umoddi3+0xae>
230006b2:	01000637          	lui	a2,0x1000
230006b6:	4741                	li	a4,16
230006b8:	f8c8e1e3          	bltu	a7,a2,2300063a <__umoddi3+0xdc>
230006bc:	4761                	li	a4,24
230006be:	bfb5                	j	2300063a <__umoddi3+0xdc>
230006c0:	006898b3          	sll	a7,a7,t1
230006c4:	01c5d733          	srl	a4,a1,t3
230006c8:	006517b3          	sll	a5,a0,t1
230006cc:	01c55e33          	srl	t3,a0,t3
230006d0:	0108d513          	srli	a0,a7,0x10
230006d4:	02a776b3          	remu	a3,a4,a0
230006d8:	006595b3          	sll	a1,a1,t1
230006dc:	00be6e33          	or	t3,t3,a1
230006e0:	01089593          	slli	a1,a7,0x10
230006e4:	81c1                	srli	a1,a1,0x10
230006e6:	010e5613          	srli	a2,t3,0x10
230006ea:	02a75733          	divu	a4,a4,a0
230006ee:	06c2                	slli	a3,a3,0x10
230006f0:	8ed1                	or	a3,a3,a2
230006f2:	02e58733          	mul	a4,a1,a4
230006f6:	00e6f863          	bgeu	a3,a4,23000706 <__umoddi3+0x1a8>
230006fa:	96c6                	add	a3,a3,a7
230006fc:	0116e563          	bltu	a3,a7,23000706 <__umoddi3+0x1a8>
23000700:	00e6f363          	bgeu	a3,a4,23000706 <__umoddi3+0x1a8>
23000704:	96c6                	add	a3,a3,a7
23000706:	40e68633          	sub	a2,a3,a4
2300070a:	02a676b3          	remu	a3,a2,a0
2300070e:	0e42                	slli	t3,t3,0x10
23000710:	010e5e13          	srli	t3,t3,0x10
23000714:	02a65633          	divu	a2,a2,a0
23000718:	06c2                	slli	a3,a3,0x10
2300071a:	02c58633          	mul	a2,a1,a2
2300071e:	01c6e5b3          	or	a1,a3,t3
23000722:	00c5f863          	bgeu	a1,a2,23000732 <__umoddi3+0x1d4>
23000726:	95c6                	add	a1,a1,a7
23000728:	0115e563          	bltu	a1,a7,23000732 <__umoddi3+0x1d4>
2300072c:	00c5f363          	bgeu	a1,a2,23000732 <__umoddi3+0x1d4>
23000730:	95c6                	add	a1,a1,a7
23000732:	8d91                	sub	a1,a1,a2
23000734:	b70d                	j	23000656 <__umoddi3+0xf8>
23000736:	ecd5eee3          	bltu	a1,a3,23000612 <__umoddi3+0xb4>
2300073a:	6741                	lui	a4,0x10
2300073c:	04e6f563          	bgeu	a3,a4,23000786 <__umoddi3+0x228>
23000740:	0ff00e93          	li	t4,255
23000744:	00deb733          	sltu	a4,t4,a3
23000748:	070e                	slli	a4,a4,0x3
2300074a:	00e6d333          	srl	t1,a3,a4
2300074e:	00006897          	auipc	a7,0x6
23000752:	f9288893          	addi	a7,a7,-110 # 230066e0 <__clz_tab>
23000756:	989a                	add	a7,a7,t1
23000758:	0008ce83          	lbu	t4,0(a7)
2300075c:	02000e13          	li	t3,32
23000760:	9eba                	add	t4,t4,a4
23000762:	41de0e33          	sub	t3,t3,t4
23000766:	020e1763          	bnez	t3,23000794 <__umoddi3+0x236>
2300076a:	00b6e463          	bltu	a3,a1,23000772 <__umoddi3+0x214>
2300076e:	00c56963          	bltu	a0,a2,23000780 <__umoddi3+0x222>
23000772:	40c507b3          	sub	a5,a0,a2
23000776:	8d95                	sub	a1,a1,a3
23000778:	00f53533          	sltu	a0,a0,a5
2300077c:	40a58833          	sub	a6,a1,a0
23000780:	853e                	mv	a0,a5
23000782:	85c2                	mv	a1,a6
23000784:	b579                	j	23000612 <__umoddi3+0xb4>
23000786:	010008b7          	lui	a7,0x1000
2300078a:	4741                	li	a4,16
2300078c:	fb16efe3          	bltu	a3,a7,2300074a <__umoddi3+0x1ec>
23000790:	4761                	li	a4,24
23000792:	bf65                	j	2300074a <__umoddi3+0x1ec>
23000794:	01d65733          	srl	a4,a2,t4
23000798:	01c696b3          	sll	a3,a3,t3
2300079c:	8ed9                	or	a3,a3,a4
2300079e:	0106d813          	srli	a6,a3,0x10
230007a2:	01d5d733          	srl	a4,a1,t4
230007a6:	03077333          	remu	t1,a4,a6
230007aa:	01c595b3          	sll	a1,a1,t3
230007ae:	01d557b3          	srl	a5,a0,t4
230007b2:	8fcd                	or	a5,a5,a1
230007b4:	01069593          	slli	a1,a3,0x10
230007b8:	81c1                	srli	a1,a1,0x10
230007ba:	0107d893          	srli	a7,a5,0x10
230007be:	01c61633          	sll	a2,a2,t3
230007c2:	01c51533          	sll	a0,a0,t3
230007c6:	03075733          	divu	a4,a4,a6
230007ca:	0342                	slli	t1,t1,0x10
230007cc:	011368b3          	or	a7,t1,a7
230007d0:	02e58f33          	mul	t5,a1,a4
230007d4:	833a                	mv	t1,a4
230007d6:	01e8fc63          	bgeu	a7,t5,230007ee <__umoddi3+0x290>
230007da:	98b6                	add	a7,a7,a3
230007dc:	fff70313          	addi	t1,a4,-1 # ffff <HeapSize+0xefff>
230007e0:	00d8e763          	bltu	a7,a3,230007ee <__umoddi3+0x290>
230007e4:	01e8f563          	bgeu	a7,t5,230007ee <__umoddi3+0x290>
230007e8:	ffe70313          	addi	t1,a4,-2
230007ec:	98b6                	add	a7,a7,a3
230007ee:	41e888b3          	sub	a7,a7,t5
230007f2:	0308ff33          	remu	t5,a7,a6
230007f6:	0308d8b3          	divu	a7,a7,a6
230007fa:	0f42                	slli	t5,t5,0x10
230007fc:	03158833          	mul	a6,a1,a7
23000800:	01079593          	slli	a1,a5,0x10
23000804:	81c1                	srli	a1,a1,0x10
23000806:	00bf65b3          	or	a1,t5,a1
2300080a:	87c6                	mv	a5,a7
2300080c:	0105fc63          	bgeu	a1,a6,23000824 <__umoddi3+0x2c6>
23000810:	95b6                	add	a1,a1,a3
23000812:	fff88793          	addi	a5,a7,-1 # ffffff <HeapSize+0xffefff>
23000816:	00d5e763          	bltu	a1,a3,23000824 <__umoddi3+0x2c6>
2300081a:	0105f563          	bgeu	a1,a6,23000824 <__umoddi3+0x2c6>
2300081e:	ffe88793          	addi	a5,a7,-2
23000822:	95b6                	add	a1,a1,a3
23000824:	0342                	slli	t1,t1,0x10
23000826:	6f41                	lui	t5,0x10
23000828:	00f36333          	or	t1,t1,a5
2300082c:	ffff0793          	addi	a5,t5,-1 # ffff <HeapSize+0xefff>
23000830:	00f378b3          	and	a7,t1,a5
23000834:	410585b3          	sub	a1,a1,a6
23000838:	01035313          	srli	t1,t1,0x10
2300083c:	01065813          	srli	a6,a2,0x10
23000840:	8ff1                	and	a5,a5,a2
23000842:	02f88733          	mul	a4,a7,a5
23000846:	02f307b3          	mul	a5,t1,a5
2300084a:	030888b3          	mul	a7,a7,a6
2300084e:	03030333          	mul	t1,t1,a6
23000852:	98be                	add	a7,a7,a5
23000854:	01075813          	srli	a6,a4,0x10
23000858:	9846                	add	a6,a6,a7
2300085a:	00f87363          	bgeu	a6,a5,23000860 <__umoddi3+0x302>
2300085e:	937a                	add	t1,t1,t5
23000860:	01085793          	srli	a5,a6,0x10
23000864:	933e                	add	t1,t1,a5
23000866:	67c1                	lui	a5,0x10
23000868:	17fd                	addi	a5,a5,-1
2300086a:	00f87833          	and	a6,a6,a5
2300086e:	0842                	slli	a6,a6,0x10
23000870:	8f7d                	and	a4,a4,a5
23000872:	9742                	add	a4,a4,a6
23000874:	0065e663          	bltu	a1,t1,23000880 <__umoddi3+0x322>
23000878:	00659c63          	bne	a1,t1,23000890 <__umoddi3+0x332>
2300087c:	00e57a63          	bgeu	a0,a4,23000890 <__umoddi3+0x332>
23000880:	40c70633          	sub	a2,a4,a2
23000884:	00c73733          	sltu	a4,a4,a2
23000888:	9736                	add	a4,a4,a3
2300088a:	40e30333          	sub	t1,t1,a4
2300088e:	8732                	mv	a4,a2
23000890:	40e50733          	sub	a4,a0,a4
23000894:	00e53533          	sltu	a0,a0,a4
23000898:	406585b3          	sub	a1,a1,t1
2300089c:	8d89                	sub	a1,a1,a0
2300089e:	01d597b3          	sll	a5,a1,t4
230008a2:	01c75733          	srl	a4,a4,t3
230008a6:	00e7e533          	or	a0,a5,a4
230008aa:	01c5d5b3          	srl	a1,a1,t3
230008ae:	b395                	j	23000612 <__umoddi3+0xb4>

230008b0 <led_set>:
	return;
}

void led_set(uint8_t idx, uint8_t status)
{
    gpio_write(led_pins[idx], !status);
230008b0:	230067b7          	lui	a5,0x23006
230008b4:	00251713          	slli	a4,a0,0x2
230008b8:	a5478793          	addi	a5,a5,-1452 # 23005a54 <led_pins>
{
230008bc:	1141                	addi	sp,sp,-16
    gpio_write(led_pins[idx], !status);
230008be:	97ba                	add	a5,a5,a4
{
230008c0:	c226                	sw	s1,4(sp)
230008c2:	84aa                	mv	s1,a0
    gpio_write(led_pins[idx], !status);
230008c4:	4388                	lw	a0,0(a5)
{
230008c6:	c422                	sw	s0,8(sp)
230008c8:	842e                	mv	s0,a1
    gpio_write(led_pins[idx], !status);
230008ca:	0015b593          	seqz	a1,a1
{
230008ce:	c606                	sw	ra,12(sp)
    gpio_write(led_pins[idx], !status);
230008d0:	16e010ef          	jal	ra,23001a3e <gpio_write>
	led_stat[idx] = status;
230008d4:	42025537          	lui	a0,0x42025
230008d8:	42050513          	addi	a0,a0,1056 # 42025420 <led_stat>
230008dc:	9526                	add	a0,a0,s1
230008de:	00850023          	sb	s0,0(a0)
	return;
}
230008e2:	40b2                	lw	ra,12(sp)
230008e4:	4422                	lw	s0,8(sp)
230008e6:	4492                	lw	s1,4(sp)
230008e8:	0141                	addi	sp,sp,16
230008ea:	8082                	ret

230008ec <led_toggle>:

void led_toggle(uint8_t idx)
{
	led_stat[idx] = !led_stat[idx];
230008ec:	420257b7          	lui	a5,0x42025
230008f0:	42078793          	addi	a5,a5,1056 # 42025420 <led_stat>
230008f4:	97aa                	add	a5,a5,a0
230008f6:	0007c703          	lbu	a4,0(a5)
230008fa:	0ff77713          	andi	a4,a4,255
230008fe:	00173713          	seqz	a4,a4
23000902:	00e78023          	sb	a4,0(a5)
    gpio_write(led_pins[idx], !led_stat[idx]);
23000906:	0007c583          	lbu	a1,0(a5)
2300090a:	00251793          	slli	a5,a0,0x2
2300090e:	23006537          	lui	a0,0x23006
23000912:	a5450513          	addi	a0,a0,-1452 # 23005a54 <led_pins>
23000916:	953e                	add	a0,a0,a5
23000918:	4108                	lw	a0,0(a0)
2300091a:	0ff5f593          	andi	a1,a1,255
2300091e:	0015b593          	seqz	a1,a1
23000922:	11c0106f          	j	23001a3e <gpio_write>

23000926 <usbd_ftdi_set_line_coding>:
}

/************************  API for usbd_ftdi  ************************/
void usbd_ftdi_set_line_coding(uint32_t baudrate, uint8_t databits, uint8_t parity, uint8_t stopbits)
{
    uart1_config(baudrate, databits, parity, stopbits);
23000926:	ab01                	j	23000e36 <uart1_config>

23000928 <usbd_ftdi_set_dtr>:
}

void usbd_ftdi_set_dtr(bool dtr)
{
    dtr_pin_set(!dtr);
23000928:	00154513          	xori	a0,a0,1
2300092c:	a361                	j	23000eb4 <dtr_pin_set>

2300092e <usbd_ftdi_set_rts>:
}

void usbd_ftdi_set_rts(bool rts)
{
    rts_pin_set(!rts);
2300092e:	00154513          	xori	a0,a0,1
23000932:	ab41                	j	23000ec2 <rts_pin_set>

23000934 <usb_dc_ftdi_send_from_ringbuffer>:
    uint8_t ep_idx;
    uint32_t timeout = 0x00FFFFFF;

    ep_idx = USB_EP_GET_IDX(ep);
    /* Check if IN ep */
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN)
23000934:	01861793          	slli	a5,a2,0x18
23000938:	87e1                	srai	a5,a5,0x18
2300093a:	0207c763          	bltz	a5,23000968 <usb_dc_ftdi_send_from_ringbuffer+0x34>
    {
        return -USB_DC_EP_DIR_ERR;
2300093e:	6541                	lui	a0,0x10
23000940:	157d                	addi	a0,a0,-1
                USB_Set_EPx_Rdy(ep_idx);
        }
        return -USB_DC_RB_SIZE_SMALL_ERR;
    }

}
23000942:	8082                	ret
        if (!timeout)
23000944:	147d                	addi	s0,s0,-1
23000946:	ec15                	bnez	s0,23000982 <usb_dc_ftdi_send_from_ringbuffer+0x4e>
            MSG("ep%d wait free timeout\r\n", ep);
23000948:	23006537          	lui	a0,0x23006
2300094c:	a5c50513          	addi	a0,a0,-1444 # 23005a5c <led_pins+0x8>
23000950:	85ca                	mv	a1,s2
23000952:	7a0000ef          	jal	ra,230010f2 <bflb_platform_printf>
            return -USB_DC_EP_TIMEOUT_ERR;
23000956:	6541                	lui	a0,0x10
23000958:	1575                	addi	a0,a0,-3
}
2300095a:	50b2                	lw	ra,44(sp)
2300095c:	5422                	lw	s0,40(sp)
2300095e:	5492                	lw	s1,36(sp)
23000960:	5902                	lw	s2,32(sp)
23000962:	49f2                	lw	s3,28(sp)
23000964:	6145                	addi	sp,sp,48
23000966:	8082                	ret
{
23000968:	7179                	addi	sp,sp,-48
2300096a:	d422                	sw	s0,40(sp)
    ep_idx = USB_EP_GET_IDX(ep);
2300096c:	01000437          	lui	s0,0x1000
{
23000970:	d226                	sw	s1,36(sp)
23000972:	d04a                	sw	s2,32(sp)
23000974:	ce4e                	sw	s3,28(sp)
23000976:	d606                	sw	ra,44(sp)
23000978:	8932                	mv	s2,a2
2300097a:	89ae                	mv	s3,a1
    ep_idx = USB_EP_GET_IDX(ep);
2300097c:	07f67493          	andi	s1,a2,127
23000980:	147d                	addi	s0,s0,-1
    while (!USB_Is_EPx_RDY_Free(ep_idx))
23000982:	8526                	mv	a0,s1
23000984:	739020ef          	jal	ra,230038bc <USB_Is_EPx_RDY_Free>
23000988:	dd55                	beqz	a0,23000944 <usb_dc_ftdi_send_from_ringbuffer+0x10>
    if ((USB_Get_EPx_TX_FIFO_CNT(ep_idx) == USB_FS_MAX_PACKET_SIZE) && Ring_Buffer_Get_Length(rb))
2300098a:	8526                	mv	a0,s1
2300098c:	61c030ef          	jal	ra,23003fa8 <USB_Get_EPx_TX_FIFO_CNT>
    uint32_t addr = USB_BASE + 0x118 + (ep_idx - 1) * 0x10;
23000990:	fff48413          	addi	s0,s1,-1
23000994:	4000e6b7          	lui	a3,0x4000e
23000998:	0412                	slli	s0,s0,0x4
2300099a:	91868693          	addi	a3,a3,-1768 # 4000d918 <__ram_load_addr+0x1d0009f4>
    if ((USB_Get_EPx_TX_FIFO_CNT(ep_idx) == USB_FS_MAX_PACKET_SIZE) && Ring_Buffer_Get_Length(rb))
2300099e:	04000793          	li	a5,64
    uint32_t addr = USB_BASE + 0x118 + (ep_idx - 1) * 0x10;
230009a2:	9436                	add	s0,s0,a3
    if ((USB_Get_EPx_TX_FIFO_CNT(ep_idx) == USB_FS_MAX_PACKET_SIZE) && Ring_Buffer_Get_Length(rb))
230009a4:	04f51063          	bne	a0,a5,230009e4 <usb_dc_ftdi_send_from_ringbuffer+0xb0>
230009a8:	854e                	mv	a0,s3
230009aa:	67f040ef          	jal	ra,23005828 <Ring_Buffer_Get_Length>
230009ae:	c91d                	beqz	a0,230009e4 <usb_dc_ftdi_send_from_ringbuffer+0xb0>
        uint8_t ftdi_header[2] = {0x01,0x60};
230009b0:	6799                	lui	a5,0x6
230009b2:	0785                	addi	a5,a5,1
        memcopy_to_fifo((void *)addr,ftdi_header,2);
230009b4:	4609                	li	a2,2
230009b6:	006c                	addi	a1,sp,12
230009b8:	8522                	mv	a0,s0
        uint8_t ftdi_header[2] = {0x01,0x60};
230009ba:	00f11623          	sh	a5,12(sp)
        memcopy_to_fifo((void *)addr,ftdi_header,2);
230009be:	5d9040ef          	jal	ra,23005796 <memcopy_to_fifo>
        Ring_Buffer_Read_Callback(rb, USB_FS_MAX_PACKET_SIZE-2, memcopy_to_fifo, (void *)addr);
230009c2:	23005637          	lui	a2,0x23005
230009c6:	86a2                	mv	a3,s0
230009c8:	79660613          	addi	a2,a2,1942 # 23005796 <memcopy_to_fifo>
230009cc:	03e00593          	li	a1,62
230009d0:	854e                	mv	a0,s3
230009d2:	6a7040ef          	jal	ra,23005878 <Ring_Buffer_Read_Callback>
        USB_Set_EPx_Rdy(ep_idx);
230009d6:	8526                	mv	a0,s1
230009d8:	623020ef          	jal	ra,230037fa <USB_Set_EPx_Rdy>
		led_toggle(0);	//RX indication
230009dc:	4501                	li	a0,0
230009de:	3739                	jal	230008ec <led_toggle>
        return 0;
230009e0:	4501                	li	a0,0
230009e2:	bfa5                	j	2300095a <usb_dc_ftdi_send_from_ringbuffer+0x26>
                uint8_t ftdi_header[2] = {0x01,0x60};     
230009e4:	6799                	lui	a5,0x6
230009e6:	0785                	addi	a5,a5,1
                memcopy_to_fifo((void *)addr,ftdi_header,2);
230009e8:	4609                	li	a2,2
230009ea:	006c                	addi	a1,sp,12
230009ec:	8522                	mv	a0,s0
                uint8_t ftdi_header[2] = {0x01,0x60};     
230009ee:	00f11623          	sh	a5,12(sp)
                memcopy_to_fifo((void *)addr,ftdi_header,2);
230009f2:	5a5040ef          	jal	ra,23005796 <memcopy_to_fifo>
                USB_Set_EPx_Rdy(ep_idx);
230009f6:	8526                	mv	a0,s1
230009f8:	603020ef          	jal	ra,230037fa <USB_Set_EPx_Rdy>
        return -USB_DC_RB_SIZE_SMALL_ERR;
230009fc:	6541                	lui	a0,0x10
230009fe:	1571                	addi	a0,a0,-4
23000a00:	bfa9                	j	2300095a <usb_dc_ftdi_send_from_ringbuffer+0x26>

23000a02 <usbd_cdc_acm_bulk_in>:
    usb_dc_ftdi_receive_to_ringbuffer(usb_fs, &usb_rx_rb, ep);
}
//UART -> USB in
void usbd_cdc_acm_bulk_in(uint8_t ep)
{
    usb_dc_ftdi_send_from_ringbuffer(usb_fs, &uart1_rx_rb, ep);
23000a02:	420257b7          	lui	a5,0x42025
23000a06:	862a                	mv	a2,a0
23000a08:	4247a503          	lw	a0,1060(a5) # 42025424 <usb_fs>
23000a0c:	420245b7          	lui	a1,0x42024
23000a10:	2c058593          	addi	a1,a1,704 # 420242c0 <uart1_rx_rb>
23000a14:	b705                	j	23000934 <usb_dc_ftdi_send_from_ringbuffer>

23000a16 <usb_dc_ftdi_receive_to_ringbuffer>:
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT)
23000a16:	01861793          	slli	a5,a2,0x18
23000a1a:	87e1                	srai	a5,a5,0x18
        return -USB_DC_EP_DIR_ERR;
23000a1c:	557d                	li	a0,-1
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT)
23000a1e:	0a07c663          	bltz	a5,23000aca <usb_dc_ftdi_receive_to_ringbuffer+0xb4>
{
23000a22:	7179                	addi	sp,sp,-48
23000a24:	d04a                	sw	s2,32(sp)
23000a26:	01000937          	lui	s2,0x1000
23000a2a:	d422                	sw	s0,40(sp)
23000a2c:	d226                	sw	s1,36(sp)
23000a2e:	d606                	sw	ra,44(sp)
23000a30:	ce4e                	sw	s3,28(sp)
23000a32:	8432                	mv	s0,a2
23000a34:	84ae                	mv	s1,a1
23000a36:	197d                	addi	s2,s2,-1
    while (!USB_Is_EPx_RDY_Free(ep_idx))
23000a38:	8522                	mv	a0,s0
23000a3a:	683020ef          	jal	ra,230038bc <USB_Is_EPx_RDY_Free>
23000a3e:	c121                	beqz	a0,23000a7e <usb_dc_ftdi_receive_to_ringbuffer+0x68>
    recv_len = USB_Get_EPx_RX_FIFO_CNT(ep_idx);
23000a40:	8522                	mv	a0,s0
23000a42:	5d4030ef          	jal	ra,23004016 <USB_Get_EPx_RX_FIFO_CNT>
23000a46:	0ff57593          	andi	a1,a0,255
    if(overflow_flag && (Ring_Buffer_Get_Empty_Length(rb)>64) && (!recv_len))
23000a4a:	420257b7          	lui	a5,0x42025
23000a4e:	42278913          	addi	s2,a5,1058 # 42025422 <overflow_flag.9377>
23000a52:	00094703          	lbu	a4,0(s2) # 1000000 <HeapSize+0xfff000>
23000a56:	42278993          	addi	s3,a5,1058
23000a5a:	c71d                	beqz	a4,23000a88 <usb_dc_ftdi_receive_to_ringbuffer+0x72>
23000a5c:	8526                	mv	a0,s1
23000a5e:	c62e                	sw	a1,12(sp)
23000a60:	6c9040ef          	jal	ra,23005928 <Ring_Buffer_Get_Empty_Length>
23000a64:	04000793          	li	a5,64
23000a68:	45b2                	lw	a1,12(sp)
23000a6a:	00a7ff63          	bgeu	a5,a0,23000a88 <usb_dc_ftdi_receive_to_ringbuffer+0x72>
23000a6e:	ed89                	bnez	a1,23000a88 <usb_dc_ftdi_receive_to_ringbuffer+0x72>
        overflow_flag = false;
23000a70:	00090023          	sb	zero,0(s2)
        USB_Set_EPx_Rdy(ep_idx);
23000a74:	8522                	mv	a0,s0
23000a76:	585020ef          	jal	ra,230037fa <USB_Set_EPx_Rdy>
        return 0;
23000a7a:	4501                	li	a0,0
23000a7c:	a081                	j	23000abc <usb_dc_ftdi_receive_to_ringbuffer+0xa6>
        if (!timeout)
23000a7e:	197d                	addi	s2,s2,-1
23000a80:	fa091ce3          	bnez	s2,23000a38 <usb_dc_ftdi_receive_to_ringbuffer+0x22>
            return -USB_DC_EP_TIMEOUT_ERR;
23000a84:	5575                	li	a0,-3
23000a86:	a81d                	j	23000abc <usb_dc_ftdi_receive_to_ringbuffer+0xa6>
        uint32_t addr = USB_BASE + 0x11C + (ep_idx - 1) * 0x10;
23000a88:	fff40693          	addi	a3,s0,-1 # ffffff <HeapSize+0xffefff>
        Ring_Buffer_Write_Callback(rb, recv_len, fifocopy_to_mem, (void *)addr);
23000a8c:	4000e7b7          	lui	a5,0x4000e
23000a90:	91c78793          	addi	a5,a5,-1764 # 4000d91c <__ram_load_addr+0x1d0009f8>
        uint32_t addr = USB_BASE + 0x11C + (ep_idx - 1) * 0x10;
23000a94:	0692                	slli	a3,a3,0x4
        Ring_Buffer_Write_Callback(rb, recv_len, fifocopy_to_mem, (void *)addr);
23000a96:	23005637          	lui	a2,0x23005
23000a9a:	96be                	add	a3,a3,a5
23000a9c:	7aa60613          	addi	a2,a2,1962 # 230057aa <fifocopy_to_mem>
23000aa0:	8526                	mv	a0,s1
23000aa2:	69f040ef          	jal	ra,23005940 <Ring_Buffer_Write_Callback>
        if(Ring_Buffer_Get_Empty_Length(rb) < 64)
23000aa6:	8526                	mv	a0,s1
23000aa8:	681040ef          	jal	ra,23005928 <Ring_Buffer_Get_Empty_Length>
23000aac:	03f00793          	li	a5,63
23000ab0:	fca7e2e3          	bltu	a5,a0,23000a74 <usb_dc_ftdi_receive_to_ringbuffer+0x5e>
            overflow_flag = true;
23000ab4:	4785                	li	a5,1
23000ab6:	00f98023          	sb	a5,0(s3)
            return -USB_DC_RB_SIZE_SMALL_ERR;
23000aba:	5571                	li	a0,-4
}
23000abc:	50b2                	lw	ra,44(sp)
23000abe:	5422                	lw	s0,40(sp)
23000ac0:	5492                	lw	s1,36(sp)
23000ac2:	5902                	lw	s2,32(sp)
23000ac4:	49f2                	lw	s3,28(sp)
23000ac6:	6145                	addi	sp,sp,48
23000ac8:	8082                	ret
23000aca:	8082                	ret

23000acc <usbd_cdc_acm_bulk_out>:
    usb_dc_ftdi_receive_to_ringbuffer(usb_fs, &usb_rx_rb, ep);
23000acc:	420257b7          	lui	a5,0x42025
23000ad0:	862a                	mv	a2,a0
23000ad2:	4247a503          	lw	a0,1060(a5) # 42025424 <usb_fs>
23000ad6:	420245b7          	lui	a1,0x42024
23000ada:	2e058593          	addi	a1,a1,736 # 420242e0 <usb_rx_rb>
23000ade:	bf25                	j	23000a16 <usb_dc_ftdi_receive_to_ringbuffer>

23000ae0 <main>:
	}
	return;
}

int main(void)
{
23000ae0:	1101                	addi	sp,sp,-32
23000ae2:	ce06                	sw	ra,28(sp)
23000ae4:	cc22                	sw	s0,24(sp)
    uint8_t chipid[8];
    uint8_t chipid2[6];
    GLB_Select_Internal_Flash();
23000ae6:	ff015097          	auipc	ra,0xff015
23000aea:	d0e080e7          	jalr	-754(ra) # 220157f4 <GLB_Select_Internal_Flash>
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+6] = 	0x33; //chipid2[3];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+8] = 	0x44; //chipid2[4];
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+10] = 	0x55; //chipid2[5];
    usbd_desc_register(cdc_descriptor);

    usbd_ftdi_add_interface(&cdc_class0,&cdc_data_intf0);
23000aee:	42024437          	lui	s0,0x42024
    bflb_platform_init(0);
23000af2:	4501                	li	a0,0
23000af4:	2da9                	jal	2300114e <bflb_platform_init>
    uart_ringbuffer_init();
23000af6:	2ee9                	jal	23000ed0 <uart_ringbuffer_init>
    uart1_init();
23000af8:	2c5d                	jal	23000dae <uart1_init>
    uart1_set_dtr_rts(UART_DTR_PIN,UART_RTS_PIN);
23000afa:	02100593          	li	a1,33
23000afe:	02500513          	li	a0,37
23000b02:	2651                	jal	23000e86 <uart1_set_dtr_rts>
    uart1_dtr_init();
23000b04:	2e51                	jal	23000e98 <uart1_dtr_init>
    uart1_rts_init();
23000b06:	2645                	jal	23000ea6 <uart1_rts_init>
    gpio_set_mode(led_pins[0], GPIO_OUTPUT_MODE);
23000b08:	4581                	li	a1,0
23000b0a:	4525                	li	a0,9
23000b0c:	615000ef          	jal	ra,23001920 <gpio_set_mode>
    gpio_set_mode(led_pins[1], GPIO_OUTPUT_MODE);
23000b10:	4581                	li	a1,0
23000b12:	4545                	li	a0,17
23000b14:	60d000ef          	jal	ra,23001920 <gpio_set_mode>
	led_set(0, 1);	//led0 for RX indication
23000b18:	4585                	li	a1,1
23000b1a:	4501                	li	a0,0
23000b1c:	3b51                	jal	230008b0 <led_set>
	led_set(1, 1);	//led1 for TX indication
23000b1e:	4585                	li	a1,1
23000b20:	4505                	li	a0,1
23000b22:	3379                	jal	230008b0 <led_set>
    jtag_ringbuffer_init();
23000b24:	29f9                	jal	23001002 <jtag_ringbuffer_init>
    jtag_gpio_init();
23000b26:	2b29                	jal	23001040 <jtag_gpio_init>
    EF_Ctrl_Read_Chip_ID(chipid);
23000b28:	0028                	addi	a0,sp,8
23000b2a:	348020ef          	jal	ra,23002e72 <EF_Ctrl_Read_Chip_ID>
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24] = 	0x00; //chipid2[0];
23000b2e:	42024537          	lui	a0,0x42024
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+2] = 	0x11; //chipid2[1];
23000b32:	4745                	li	a4,17
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24] = 	0x00; //chipid2[0];
23000b34:	04050793          	addi	a5,a0,64 # 42024040 <cdc_descriptor>
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+2] = 	0x11; //chipid2[1];
23000b38:	08e78ca3          	sb	a4,153(a5)
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+4] = 	0x22; //chipid2[2];
23000b3c:	02200713          	li	a4,34
23000b40:	08e78da3          	sb	a4,155(a5)
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+6] = 	0x33; //chipid2[3];
23000b44:	03300713          	li	a4,51
23000b48:	08e78ea3          	sb	a4,157(a5)
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+8] = 	0x44; //chipid2[4];
23000b4c:	04400713          	li	a4,68
23000b50:	08e78fa3          	sb	a4,159(a5)
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+10] = 	0x55; //chipid2[5];
23000b54:	05500713          	li	a4,85
    usbd_desc_register(cdc_descriptor);
23000b58:	04050513          	addi	a0,a0,64
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24+10] = 	0x55; //chipid2[5];
23000b5c:	0ae780a3          	sb	a4,161(a5)
    cdc_descriptor[0x12+0x37+0x04+0x0a+0x1c+0x24] = 	0x00; //chipid2[0];
23000b60:	08078ba3          	sb	zero,151(a5)
    usbd_desc_register(cdc_descriptor);
23000b64:	70f030ef          	jal	ra,23004a72 <usbd_desc_register>
    usbd_ftdi_add_interface(&cdc_class0,&cdc_data_intf0);
23000b68:	42024537          	lui	a0,0x42024
23000b6c:	28840593          	addi	a1,s0,648 # 42024288 <cdc_data_intf0>
23000b70:	27050513          	addi	a0,a0,624 # 42024270 <__ram_data_end__>
23000b74:	742030ef          	jal	ra,230042b6 <usbd_ftdi_add_interface>
    usbd_interface_add_endpoint(&cdc_data_intf0,&cdc_out_ep0);
23000b78:	420245b7          	lui	a1,0x42024
23000b7c:	28840513          	addi	a0,s0,648
23000b80:	01858593          	addi	a1,a1,24 # 42024018 <cdc_out_ep0>
23000b84:	741030ef          	jal	ra,23004ac4 <usbd_interface_add_endpoint>
    usbd_interface_add_endpoint(&cdc_data_intf0,&cdc_in_ep0);
23000b88:	420245b7          	lui	a1,0x42024
23000b8c:	28840513          	addi	a0,s0,648
23000b90:	00058593          	mv	a1,a1
23000b94:	731030ef          	jal	ra,23004ac4 <usbd_interface_add_endpoint>

    usbd_ftdi_add_interface(&cdc_class1,&cdc_data_intf1);
23000b98:	42024437          	lui	s0,0x42024
23000b9c:	42024537          	lui	a0,0x42024
23000ba0:	2a440593          	addi	a1,s0,676 # 420242a4 <cdc_data_intf1>
23000ba4:	27c50513          	addi	a0,a0,636 # 4202427c <cdc_class1>
23000ba8:	70e030ef          	jal	ra,230042b6 <usbd_ftdi_add_interface>
    usbd_interface_add_endpoint(&cdc_data_intf1,&cdc_out_ep1);
23000bac:	420245b7          	lui	a1,0x42024
23000bb0:	02458593          	addi	a1,a1,36 # 42024024 <cdc_out_ep1>
23000bb4:	2a440513          	addi	a0,s0,676
23000bb8:	70d030ef          	jal	ra,23004ac4 <usbd_interface_add_endpoint>
    usbd_interface_add_endpoint(&cdc_data_intf1,&cdc_in_ep1);
23000bbc:	420245b7          	lui	a1,0x42024
23000bc0:	00c58593          	addi	a1,a1,12 # 4202400c <cdc_in_ep1>
23000bc4:	2a440513          	addi	a0,s0,676
23000bc8:	6fd030ef          	jal	ra,23004ac4 <usbd_interface_add_endpoint>

    usb_fs = usb_dc_init();
23000bcc:	28ad                	jal	23000c46 <usb_dc_init>
23000bce:	42025737          	lui	a4,0x42025
23000bd2:	42a72223          	sw	a0,1060(a4) # 42025424 <usb_fs>
    if (usb_fs)
23000bd6:	c901                	beqz	a0,23000be6 <main+0x106>
    {
        device_control(usb_fs, DEVICE_CTRL_SET_INT, (void *)(USB_SOF_IT|USB_EP2_DATA_OUT_IT | USB_EP1_DATA_IN_IT|USB_EP4_DATA_OUT_IT|USB_EP3_DATA_IN_IT));
23000bd8:	00026637          	lui	a2,0x26
23000bdc:	40160613          	addi	a2,a2,1025 # 26401 <HeapSize+0x25401>
23000be0:	4585                	li	a1,1
23000be2:	7d7030ef          	jal	ra,23004bb8 <device_control>
    }
    while(!usb_device_is_configured()){};
23000be6:	6f1030ef          	jal	ra,23004ad6 <usb_device_is_configured>
23000bea:	dd75                	beqz	a0,23000be6 <main+0x106>
    
	led_toggle(0);
23000bec:	4501                	li	a0,0
23000bee:	39fd                	jal	230008ec <led_toggle>
	led_toggle(1);
23000bf0:	4505                	li	a0,1
23000bf2:	39ed                	jal	230008ec <led_toggle>
    while (1)
    {
        uart_send_from_ringbuffer();
23000bf4:	2e81                	jal	23000f44 <uart_send_from_ringbuffer>
        jtag_process();
23000bf6:	ff015097          	auipc	ra,0xff015
23000bfa:	0e6080e7          	jalr	230(ra) # 22015cdc <jtag_process>
    while (1)
23000bfe:	bfdd                	j	23000bf4 <main+0x114>

23000c00 <usb_dc_event_callback>:

struct device *usb;

static void usb_dc_event_callback(struct device *dev, void *args, uint32_t size, uint32_t state)
{
    switch (state)
23000c00:	47b1                	li	a5,12
23000c02:	04d7e163          	bltu	a5,a3,23000c44 <usb_dc_event_callback+0x44>
23000c06:	230067b7          	lui	a5,0x23006
23000c0a:	a7878793          	addi	a5,a5,-1416 # 23005a78 <led_pins+0x24>
23000c0e:	068a                	slli	a3,a3,0x2
23000c10:	96be                	add	a3,a3,a5
23000c12:	429c                	lw	a5,0(a3)
23000c14:	8782                	jr	a5
    {
    case USB_DC_EVENT_ERROR:
        usbd_event_notify_handler(USB_EVENT_ERROR,NULL);
23000c16:	4581                	li	a1,0
23000c18:	4501                	li	a0,0
        break;
    case USB_DC_EVENT_EP_IN_NOTIFY:
        usbd_event_notify_handler(USB_EVENT_EP_IN_NOTIFY,args);
        break;
    case USB_DC_EVENT_EP_OUT_NOTIFY:
        usbd_event_notify_handler(USB_EVENT_EP_OUT_NOTIFY,args);
23000c1a:	7b80306f          	j	230043d2 <usbd_event_notify_handler>
        usbd_event_notify_handler(USB_EVENT_RESET,NULL);
23000c1e:	4581                	li	a1,0
23000c20:	4505                	li	a0,1
23000c22:	bfe5                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_SOF,NULL);
23000c24:	4581                	li	a1,0
23000c26:	4509                	li	a0,2
23000c28:	bfcd                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_SETUP_NOTIFY,NULL);
23000c2a:	4581                	li	a1,0
23000c2c:	4535                	li	a0,13
23000c2e:	b7f5                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_EP0_IN_NOTIFY,NULL);
23000c30:	4581                	li	a1,0
23000c32:	4539                	li	a0,14
23000c34:	b7dd                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_EP0_OUT_NOTIFY,NULL);
23000c36:	4581                	li	a1,0
23000c38:	453d                	li	a0,15
23000c3a:	b7c5                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_EP_IN_NOTIFY,args);
23000c3c:	4541                	li	a0,16
23000c3e:	bff1                	j	23000c1a <usb_dc_event_callback+0x1a>
        usbd_event_notify_handler(USB_EVENT_EP_OUT_NOTIFY,args);
23000c40:	4545                	li	a0,17
23000c42:	bfe1                	j	23000c1a <usb_dc_event_callback+0x1a>
        break; 
    default:
        break;
    }
}
23000c44:	8082                	ret

23000c46 <usb_dc_init>:
struct device* usb_dc_init(void)
{
23000c46:	1141                	addi	sp,sp,-16
23000c48:	c422                	sw	s0,8(sp)
    usb_dc_register(USB_INDEX, "usb", DEVICE_OFLAG_RDWR);
23000c4a:	23006437          	lui	s0,0x23006
23000c4e:	660d                	lui	a2,0x3
23000c50:	aac40593          	addi	a1,s0,-1364 # 23005aac <led_pins+0x58>
23000c54:	4501                	li	a0,0
{
23000c56:	c606                	sw	ra,12(sp)
    usb_dc_register(USB_INDEX, "usb", DEVICE_OFLAG_RDWR);
23000c58:	6bc010ef          	jal	ra,23002314 <usb_dc_register>
    usb = device_find("usb");
23000c5c:	aac40513          	addi	a0,s0,-1364
23000c60:	6cd030ef          	jal	ra,23004b2c <device_find>
23000c64:	42025437          	lui	s0,0x42025
    device_set_callback(usb,usb_dc_event_callback);
23000c68:	230015b7          	lui	a1,0x23001
    usb = device_find("usb");
23000c6c:	42840413          	addi	s0,s0,1064 # 42025428 <usb>
    device_set_callback(usb,usb_dc_event_callback);
23000c70:	c0058593          	addi	a1,a1,-1024 # 23000c00 <usb_dc_event_callback>
    usb = device_find("usb");
23000c74:	c008                	sw	a0,0(s0)
    device_set_callback(usb,usb_dc_event_callback);
23000c76:	777030ef          	jal	ra,23004bec <device_set_callback>
    device_open(usb, 0);
23000c7a:	4008                	lw	a0,0(s0)
23000c7c:	4581                	li	a1,0
23000c7e:	6f5030ef          	jal	ra,23004b72 <device_open>
    return usb;
}
23000c82:	4008                	lw	a0,0(s0)
23000c84:	40b2                	lw	ra,12(sp)
23000c86:	4422                	lw	s0,8(sp)
23000c88:	0141                	addi	sp,sp,16
23000c8a:	8082                	ret

23000c8c <usbd_set_address>:

int usbd_set_address(const uint8_t addr)
{
    return device_control(usb,DEVICE_CTRL_USB_DC_SET_ADDR,(void*)(uint32_t)addr);
23000c8c:	420257b7          	lui	a5,0x42025
23000c90:	862a                	mv	a2,a0
23000c92:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000c96:	45c1                	li	a1,16
23000c98:	7210306f          	j	23004bb8 <device_control>

23000c9c <usbd_ep_open>:
}

int usbd_ep_open(const struct usbd_endpoint_cfg *ep_cfg)
{
    return usb_dc_ep_open(usb,(const struct usb_dc_ep_cfg*)ep_cfg);
23000c9c:	420257b7          	lui	a5,0x42025
23000ca0:	85aa                	mv	a1,a0
23000ca2:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000ca6:	6be0106f          	j	23002364 <usb_dc_ep_open>

23000caa <usbd_ep_close>:
}
int usbd_ep_close(const uint8_t ep)
{
    device_control(usb,DEVICE_CTRL_USB_DC_SET_NACK,(void*)(uint32_t)ep);
23000caa:	420257b7          	lui	a5,0x42025
23000cae:	862a                	mv	a2,a0
23000cb0:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
{
23000cb4:	1141                	addi	sp,sp,-16
    device_control(usb,DEVICE_CTRL_USB_DC_SET_NACK,(void*)(uint32_t)ep);
23000cb6:	45c9                	li	a1,18
{
23000cb8:	c606                	sw	ra,12(sp)
    device_control(usb,DEVICE_CTRL_USB_DC_SET_NACK,(void*)(uint32_t)ep);
23000cba:	6ff030ef          	jal	ra,23004bb8 <device_control>
    return 0;
}
23000cbe:	40b2                	lw	ra,12(sp)
23000cc0:	4501                	li	a0,0
23000cc2:	0141                	addi	sp,sp,16
23000cc4:	8082                	ret

23000cc6 <usbd_ep_set_stall>:
int usbd_ep_set_stall(const uint8_t ep)
{
    return device_control(usb,DEVICE_CTRL_USB_DC_SET_STALL,(void*)(uint32_t)ep);
23000cc6:	420257b7          	lui	a5,0x42025
23000cca:	862a                	mv	a2,a0
23000ccc:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000cd0:	45cd                	li	a1,19
23000cd2:	6e70306f          	j	23004bb8 <device_control>

23000cd6 <usbd_ep_clear_stall>:
}
int usbd_ep_clear_stall(const uint8_t ep)
{
    return device_control(usb,DEVICE_CTRL_USB_DC_CLR_STALL,(void*)(uint32_t)ep);
23000cd6:	420257b7          	lui	a5,0x42025
23000cda:	862a                	mv	a2,a0
23000cdc:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000ce0:	45d1                	li	a1,20
23000ce2:	6d70306f          	j	23004bb8 <device_control>

23000ce6 <usbd_ep_is_stalled>:
}
int usbd_ep_is_stalled(const uint8_t ep, uint8_t *stalled)
{
    return usb_dc_ep_is_stalled(usb,ep,stalled);
23000ce6:	420257b7          	lui	a5,0x42025
23000cea:	862e                	mv	a2,a1
23000cec:	85aa                	mv	a1,a0
23000cee:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000cf2:	7560106f          	j	23002448 <usb_dc_ep_is_stalled>

23000cf6 <usbd_ep_write>:
}

int usbd_ep_write(const uint8_t ep, const uint8_t *data, uint32_t data_len, uint32_t *ret_bytes)
{
    return usb_dc_ep_write(usb,ep,data,data_len,ret_bytes);
23000cf6:	420257b7          	lui	a5,0x42025
23000cfa:	8736                	mv	a4,a3
23000cfc:	86b2                	mv	a3,a2
23000cfe:	862e                	mv	a2,a1
23000d00:	85aa                	mv	a1,a0
23000d02:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000d06:	79e0106f          	j	230024a4 <usb_dc_ep_write>

23000d0a <usbd_ep_read>:
}

int usbd_ep_read(const uint8_t ep, uint8_t *data, uint32_t max_data_len,uint32_t *read_bytes)
{
    return usb_dc_ep_read(usb,ep,data,max_data_len,read_bytes);
23000d0a:	420257b7          	lui	a5,0x42025
23000d0e:	8736                	mv	a4,a3
23000d10:	86b2                	mv	a3,a2
23000d12:	862e                	mv	a2,a1
23000d14:	85aa                	mv	a1,a0
23000d16:	4287a503          	lw	a0,1064(a5) # 42025428 <usb>
23000d1a:	0930106f          	j	230025ac <usb_dc_ep_read>

23000d1e <ringbuffer_lock>:
  __ASM__ volatile ("csrsi mstatus, 8");
}

__attribute__( ( always_inline ) ) __STATIC_INLINE__ void disable_irq(void)
{
  __ASM__ volatile ("csrci mstatus, 8");
23000d1e:	30047073          	csrci	mstatus,8
    gpio_write(uart1_rts, status);
}
void ringbuffer_lock()
{
    disable_irq();
}
23000d22:	8082                	ret

23000d24 <ringbuffer_unlock>:
  __ASM__ volatile ("csrsi mstatus, 8");
23000d24:	30046073          	csrsi	mstatus,8
void ringbuffer_unlock()
{
    enable_irq();
}
23000d28:	8082                	ret

23000d2a <uart_irq_callback>:
{
23000d2a:	1101                	addi	sp,sp,-32
23000d2c:	ce06                	sw	ra,28(sp)
    if (state == UART_EVENT_RX_FIFO)
23000d2e:	478d                	li	a5,3
23000d30:	02f69e63          	bne	a3,a5,23000d6c <uart_irq_callback+0x42>
23000d34:	c62e                	sw	a1,12(sp)
        if (size && size < Ring_Buffer_Get_Empty_Length(&uart1_rx_rb))
23000d36:	c432                	sw	a2,8(sp)
23000d38:	c21d                	beqz	a2,23000d5e <uart_irq_callback+0x34>
23000d3a:	42024537          	lui	a0,0x42024
23000d3e:	2c050513          	addi	a0,a0,704 # 420242c0 <uart1_rx_rb>
23000d42:	3e7040ef          	jal	ra,23005928 <Ring_Buffer_Get_Empty_Length>
23000d46:	4622                	lw	a2,8(sp)
23000d48:	45b2                	lw	a1,12(sp)
23000d4a:	00a67a63          	bgeu	a2,a0,23000d5e <uart_irq_callback+0x34>
}
23000d4e:	40f2                	lw	ra,28(sp)
            Ring_Buffer_Write(&uart1_rx_rb, (uint8_t *)args, size);
23000d50:	42024537          	lui	a0,0x42024
23000d54:	2c050513          	addi	a0,a0,704 # 420242c0 <uart1_rx_rb>
}
23000d58:	6105                	addi	sp,sp,32
            Ring_Buffer_Write(&uart1_rx_rb, (uint8_t *)args, size);
23000d5a:	47d0406f          	j	230059d6 <Ring_Buffer_Write>
            MSG("RF\r\n");
23000d5e:	23006537          	lui	a0,0x23006
23000d62:	abc50513          	addi	a0,a0,-1348 # 23005abc <led_pins+0x68>
}
23000d66:	40f2                	lw	ra,28(sp)
23000d68:	6105                	addi	sp,sp,32
        MSG("ov\r\n");
23000d6a:	a661                	j	230010f2 <bflb_platform_printf>
    else if (state == UART_EVENT_RTO)
23000d6c:	4791                	li	a5,4
23000d6e:	02f69463          	bne	a3,a5,23000d96 <uart_irq_callback+0x6c>
23000d72:	c62e                	sw	a1,12(sp)
        if (size && size < Ring_Buffer_Get_Empty_Length(&uart1_rx_rb))
23000d74:	c432                	sw	a2,8(sp)
23000d76:	ca19                	beqz	a2,23000d8c <uart_irq_callback+0x62>
23000d78:	42024537          	lui	a0,0x42024
23000d7c:	2c050513          	addi	a0,a0,704 # 420242c0 <uart1_rx_rb>
23000d80:	3a9040ef          	jal	ra,23005928 <Ring_Buffer_Get_Empty_Length>
23000d84:	4622                	lw	a2,8(sp)
23000d86:	45b2                	lw	a1,12(sp)
23000d88:	fca663e3          	bltu	a2,a0,23000d4e <uart_irq_callback+0x24>
            MSG("RTO\r\n");
23000d8c:	23006537          	lui	a0,0x23006
23000d90:	ac450513          	addi	a0,a0,-1340 # 23005ac4 <led_pins+0x70>
23000d94:	bfc9                	j	23000d66 <uart_irq_callback+0x3c>
    else if (state == UART_RX_FER_IT)
23000d96:	08000793          	li	a5,128
23000d9a:	00f69763          	bne	a3,a5,23000da8 <uart_irq_callback+0x7e>
        MSG("ov\r\n");
23000d9e:	23006537          	lui	a0,0x23006
23000da2:	acc50513          	addi	a0,a0,-1332 # 23005acc <led_pins+0x78>
23000da6:	b7c1                	j	23000d66 <uart_irq_callback+0x3c>
}
23000da8:	40f2                	lw	ra,28(sp)
23000daa:	6105                	addi	sp,sp,32
23000dac:	8082                	ret

23000dae <uart1_init>:
{
23000dae:	1141                	addi	sp,sp,-16
23000db0:	c422                	sw	s0,8(sp)
    uart_register(UART1_INDEX, "uart1", DEVICE_OFLAG_RDWR);
23000db2:	23006437          	lui	s0,0x23006
23000db6:	ab040593          	addi	a1,s0,-1360 # 23005ab0 <led_pins+0x5c>
23000dba:	660d                	lui	a2,0x3
23000dbc:	4505                	li	a0,1
{
23000dbe:	c606                	sw	ra,12(sp)
    uart_register(UART1_INDEX, "uart1", DEVICE_OFLAG_RDWR);
23000dc0:	06e010ef          	jal	ra,23001e2e <uart_register>
    uart1 = device_find("uart1");
23000dc4:	ab040513          	addi	a0,s0,-1360
23000dc8:	42025437          	lui	s0,0x42025
23000dcc:	561030ef          	jal	ra,23004b2c <device_find>
23000dd0:	43040413          	addi	s0,s0,1072 # 42025430 <uart1>
23000dd4:	c008                	sw	a0,0(s0)
    if (uart1)
23000dd6:	c50d                	beqz	a0,23000e00 <uart1_init+0x52>
        device_open(uart1, DEVICE_OFLAG_DMA_TX | DEVICE_OFLAG_INT_RX); //uart0 tx dma mode
23000dd8:	45e1                	li	a1,24
23000dda:	599030ef          	jal	ra,23004b72 <device_open>
        device_control(uart1, DEVICE_CTRL_SUSPEND, NULL);
23000dde:	4008                	lw	a0,0(s0)
23000de0:	4601                	li	a2,0
23000de2:	4595                	li	a1,5
23000de4:	5d5030ef          	jal	ra,23004bb8 <device_control>
        device_set_callback(uart1, uart_irq_callback);
23000de8:	4008                	lw	a0,0(s0)
23000dea:	230015b7          	lui	a1,0x23001
23000dee:	d2a58593          	addi	a1,a1,-726 # 23000d2a <uart_irq_callback>
23000df2:	5fb030ef          	jal	ra,23004bec <device_set_callback>
        device_control(uart1, DEVICE_CTRL_SET_INT, (void *)(UART_RX_FIFO_IT | UART_RTO_IT));
23000df6:	4008                	lw	a0,0(s0)
23000df8:	4661                	li	a2,24
23000dfa:	4585                	li	a1,1
23000dfc:	5bd030ef          	jal	ra,23004bb8 <device_control>
    dma_register(DMA0_CH2_INDEX, "ch2", DEVICE_OFLAG_RDWR);
23000e00:	23006437          	lui	s0,0x23006
23000e04:	660d                	lui	a2,0x3
23000e06:	ab840593          	addi	a1,s0,-1352 # 23005ab8 <led_pins+0x64>
23000e0a:	4509                	li	a0,2
23000e0c:	700000ef          	jal	ra,2300150c <dma_register>
    dma_ch2 = device_find("ch2");
23000e10:	ab840513          	addi	a0,s0,-1352
23000e14:	519030ef          	jal	ra,23004b2c <device_find>
23000e18:	42025737          	lui	a4,0x42025
23000e1c:	42a72623          	sw	a0,1068(a4) # 4202542c <dma_ch2>
    if (dma_ch2)
23000e20:	c519                	beqz	a0,23000e2e <uart1_init+0x80>
}
23000e22:	4422                	lw	s0,8(sp)
23000e24:	40b2                	lw	ra,12(sp)
        device_open(dma_ch2, 0);
23000e26:	4581                	li	a1,0
}
23000e28:	0141                	addi	sp,sp,16
        device_open(dma_ch2, 0);
23000e2a:	5490306f          	j	23004b72 <device_open>
}
23000e2e:	40b2                	lw	ra,12(sp)
23000e30:	4422                	lw	s0,8(sp)
23000e32:	0141                	addi	sp,sp,16
23000e34:	8082                	ret

23000e36 <uart1_config>:
{
23000e36:	1101                	addi	sp,sp,-32
23000e38:	ce06                	sw	ra,28(sp)
    cfg.baudrate = baudrate;
23000e3a:	c42a                	sw	a0,8(sp)
    cfg.stopbits = stopbits;
23000e3c:	00d106a3          	sb	a3,13(sp)
    cfg.parity = parity;
23000e40:	00c10723          	sb	a2,14(sp)
    if (databits == 5)
23000e44:	4795                	li	a5,5
23000e46:	00f59f63          	bne	a1,a5,23000e64 <uart1_config+0x2e>
        cfg.databits = UART_DATA_LEN_5;
23000e4a:	00010623          	sb	zero,12(sp)
    device_control(uart1, DEVICE_CTRL_CONFIG, &cfg);
23000e4e:	420257b7          	lui	a5,0x42025
23000e52:	4307a503          	lw	a0,1072(a5) # 42025430 <uart1>
23000e56:	0030                	addi	a2,sp,8
23000e58:	4599                	li	a1,6
23000e5a:	55f030ef          	jal	ra,23004bb8 <device_control>
}
23000e5e:	40f2                	lw	ra,28(sp)
23000e60:	6105                	addi	sp,sp,32
23000e62:	8082                	ret
    else if (databits == 6)
23000e64:	4799                	li	a5,6
23000e66:	00f59663          	bne	a1,a5,23000e72 <uart1_config+0x3c>
        cfg.databits = UART_DATA_LEN_6;
23000e6a:	4785                	li	a5,1
        cfg.databits = UART_DATA_LEN_8;
23000e6c:	00f10623          	sb	a5,12(sp)
23000e70:	bff9                	j	23000e4e <uart1_config+0x18>
    else if (databits == 7)
23000e72:	479d                	li	a5,7
23000e74:	00f59463          	bne	a1,a5,23000e7c <uart1_config+0x46>
        cfg.databits = UART_DATA_LEN_7;
23000e78:	4789                	li	a5,2
23000e7a:	bfcd                	j	23000e6c <uart1_config+0x36>
    else if (databits == 8)
23000e7c:	47a1                	li	a5,8
23000e7e:	fcf598e3          	bne	a1,a5,23000e4e <uart1_config+0x18>
        cfg.databits = UART_DATA_LEN_8;
23000e82:	478d                	li	a5,3
23000e84:	b7e5                	j	23000e6c <uart1_config+0x36>

23000e86 <uart1_set_dtr_rts>:
    uart1_dtr = dtr;
23000e86:	420257b7          	lui	a5,0x42025
23000e8a:	42a78a23          	sb	a0,1076(a5) # 42025434 <uart1_dtr>
    uart1_rts = rts;
23000e8e:	420257b7          	lui	a5,0x42025
23000e92:	42b78aa3          	sb	a1,1077(a5) # 42025435 <uart1_rts>
}
23000e96:	8082                	ret

23000e98 <uart1_dtr_init>:
    gpio_set_mode(uart1_dtr, GPIO_OUTPUT_MODE);
23000e98:	420257b7          	lui	a5,0x42025
23000e9c:	4347c503          	lbu	a0,1076(a5) # 42025434 <uart1_dtr>
23000ea0:	4581                	li	a1,0
23000ea2:	27f0006f          	j	23001920 <gpio_set_mode>

23000ea6 <uart1_rts_init>:
    gpio_set_mode(uart1_rts, GPIO_OUTPUT_MODE);
23000ea6:	420257b7          	lui	a5,0x42025
23000eaa:	4357c503          	lbu	a0,1077(a5) # 42025435 <uart1_rts>
23000eae:	4581                	li	a1,0
23000eb0:	2710006f          	j	23001920 <gpio_set_mode>

23000eb4 <dtr_pin_set>:
    gpio_write(uart1_dtr, status);
23000eb4:	420257b7          	lui	a5,0x42025
23000eb8:	85aa                	mv	a1,a0
23000eba:	4347c503          	lbu	a0,1076(a5) # 42025434 <uart1_dtr>
23000ebe:	3810006f          	j	23001a3e <gpio_write>

23000ec2 <rts_pin_set>:
    gpio_write(uart1_rts, status);
23000ec2:	420257b7          	lui	a5,0x42025
23000ec6:	85aa                	mv	a1,a0
23000ec8:	4357c503          	lbu	a0,1077(a5) # 42025435 <uart1_rts>
23000ecc:	3730006f          	j	23001a3e <gpio_write>

23000ed0 <uart_ringbuffer_init>:

void uart_ringbuffer_init(void)
{
23000ed0:	1101                	addi	sp,sp,-32
23000ed2:	c64e                	sw	s3,12(sp)
    /* init mem for ring_buffer */
    memset(usb_rx_mem, 0, USB_OUT_RINGBUFFER_SIZE);
23000ed4:	420229b7          	lui	s3,0x42022
23000ed8:	6609                	lui	a2,0x2
23000eda:	4581                	li	a1,0
23000edc:	00098513          	mv	a0,s3
{
23000ee0:	ce06                	sw	ra,28(sp)
23000ee2:	cc22                	sw	s0,24(sp)
23000ee4:	ca26                	sw	s1,20(sp)
23000ee6:	c84a                	sw	s2,16(sp)
    memset(usb_rx_mem, 0, USB_OUT_RINGBUFFER_SIZE);
23000ee8:	535030ef          	jal	ra,23004c1c <memset>
    memset(uart_rx_mem, 0, UART_RX_RINGBUFFER_SIZE);
23000eec:	42020437          	lui	s0,0x42020
23000ef0:	6609                	lui	a2,0x2
23000ef2:	4581                	li	a1,0
23000ef4:	00040513          	mv	a0,s0
23000ef8:	525030ef          	jal	ra,23004c1c <memset>

    /* init ring_buffer */
    Ring_Buffer_Init(&usb_rx_rb, usb_rx_mem, USB_OUT_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
23000efc:	23001937          	lui	s2,0x23001
23000f00:	230014b7          	lui	s1,0x23001
23000f04:	42024537          	lui	a0,0x42024
23000f08:	d2490713          	addi	a4,s2,-732 # 23000d24 <ringbuffer_unlock>
23000f0c:	d1e48693          	addi	a3,s1,-738 # 23000d1e <ringbuffer_lock>
23000f10:	00098593          	mv	a1,s3
23000f14:	6609                	lui	a2,0x2
23000f16:	2e050513          	addi	a0,a0,736 # 420242e0 <usb_rx_rb>
23000f1a:	0f3040ef          	jal	ra,2300580c <Ring_Buffer_Init>
    Ring_Buffer_Init(&uart1_rx_rb, uart_rx_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
}
23000f1e:	49b2                	lw	s3,12(sp)
    Ring_Buffer_Init(&uart1_rx_rb, uart_rx_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
23000f20:	00040593          	mv	a1,s0
}
23000f24:	4462                	lw	s0,24(sp)
23000f26:	40f2                	lw	ra,28(sp)
    Ring_Buffer_Init(&uart1_rx_rb, uart_rx_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
23000f28:	d2490713          	addi	a4,s2,-732
23000f2c:	d1e48693          	addi	a3,s1,-738
}
23000f30:	4942                	lw	s2,16(sp)
23000f32:	44d2                	lw	s1,20(sp)
    Ring_Buffer_Init(&uart1_rx_rb, uart_rx_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
23000f34:	42024537          	lui	a0,0x42024
23000f38:	6609                	lui	a2,0x2
23000f3a:	2c050513          	addi	a0,a0,704 # 420242c0 <uart1_rx_rb>
}
23000f3e:	6105                	addi	sp,sp,32
    Ring_Buffer_Init(&uart1_rx_rb, uart_rx_mem, UART_RX_RINGBUFFER_SIZE, ringbuffer_lock, ringbuffer_unlock);
23000f40:	0cd0406f          	j	2300580c <Ring_Buffer_Init>

23000f44 <uart_send_from_ringbuffer>:
    .nextlli = 0
};

extern void led_toggle(uint8_t idx);
void uart_send_from_ringbuffer(void)
{
23000f44:	1141                	addi	sp,sp,-16
23000f46:	c226                	sw	s1,4(sp)
    if(Ring_Buffer_Get_Length(&usb_rx_rb))
23000f48:	420244b7          	lui	s1,0x42024
23000f4c:	2e048513          	addi	a0,s1,736 # 420242e0 <usb_rx_rb>
{
23000f50:	c606                	sw	ra,12(sp)
23000f52:	c422                	sw	s0,8(sp)
23000f54:	c04a                	sw	s2,0(sp)
    if(Ring_Buffer_Get_Length(&usb_rx_rb))
23000f56:	0d3040ef          	jal	ra,23005828 <Ring_Buffer_Get_Length>
23000f5a:	c149                	beqz	a0,23000fdc <uart_send_from_ringbuffer+0x98>
    {
        if (!device_control(dma_ch2, DMA_CHANNEL_GET_STATUS, NULL))
23000f5c:	42025437          	lui	s0,0x42025
23000f60:	42c40413          	addi	s0,s0,1068 # 4202542c <dma_ch2>
23000f64:	4008                	lw	a0,0(s0)
23000f66:	4601                	li	a2,0
23000f68:	45c1                	li	a1,16
23000f6a:	44f030ef          	jal	ra,23004bb8 <device_control>
23000f6e:	e53d                	bnez	a0,23000fdc <uart_send_from_ringbuffer+0x98>
        {
            uint32_t avalibleCnt = Ring_Buffer_Read(&usb_rx_rb, src_buffer, UART_TX_DMA_SIZE);
23000f70:	6905                	lui	s2,0x1
23000f72:	220145b7          	lui	a1,0x22014
23000f76:	2e048513          	addi	a0,s1,736
23000f7a:	fff90613          	addi	a2,s2,-1 # fff <__metal_chicken_bit+0xfff>
23000f7e:	00058593          	mv	a1,a1
23000f82:	18d040ef          	jal	ra,2300590e <Ring_Buffer_Read>
23000f86:	84aa                	mv	s1,a0
            
            if (avalibleCnt)
23000f88:	c931                	beqz	a0,23000fdc <uart_send_from_ringbuffer+0x98>
            {
                dma_channel_stop(dma_ch2);
23000f8a:	4008                	lw	a0,0(s0)
23000f8c:	4601                	li	a2,0
23000f8e:	45c9                	li	a1,18
23000f90:	429030ef          	jal	ra,23004bb8 <device_control>
                uart_dma_ctrl_cfg.bits.TransferSize = avalibleCnt;
23000f94:	fff90513          	addi	a0,s2,-1
23000f98:	420247b7          	lui	a5,0x42024
23000f9c:	26478793          	addi	a5,a5,612 # 42024264 <uart_dma_ctrl_cfg>
23000fa0:	8ce9                	and	s1,s1,a0
23000fa2:	4388                	lw	a0,0(a5)
23000fa4:	777d                	lui	a4,0xfffff
                memcpy(&uart_lli_list.cfg, &uart_dma_ctrl_cfg, sizeof(dma_control_data_t));
23000fa6:	42024637          	lui	a2,0x42024
                uart_dma_ctrl_cfg.bits.TransferSize = avalibleCnt;
23000faa:	8d79                	and	a0,a0,a4
23000fac:	8d45                	or	a0,a0,s1
23000fae:	c388                	sw	a0,0(a5)
                memcpy(&uart_lli_list.cfg, &uart_dma_ctrl_cfg, sizeof(dma_control_data_t));
23000fb0:	03060793          	addi	a5,a2,48 # 42024030 <uart_lli_list>
23000fb4:	c7c8                	sw	a0,12(a5)
                device_control(dma_ch2,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&uart_lli_list));
23000fb6:	4008                	lw	a0,0(s0)
23000fb8:	03060613          	addi	a2,a2,48
23000fbc:	45cd                	li	a1,19
23000fbe:	3fb030ef          	jal	ra,23004bb8 <device_control>
                dma_channel_start(dma_ch2);
23000fc2:	4008                	lw	a0,0(s0)
23000fc4:	4601                	li	a2,0
23000fc6:	45c5                	li	a1,17
23000fc8:	3f1030ef          	jal	ra,23004bb8 <device_control>
				led_toggle(1);	//TX indication
            }
        }
    }
}
23000fcc:	4422                	lw	s0,8(sp)
23000fce:	40b2                	lw	ra,12(sp)
23000fd0:	4492                	lw	s1,4(sp)
23000fd2:	4902                	lw	s2,0(sp)
				led_toggle(1);	//TX indication
23000fd4:	4505                	li	a0,1
}
23000fd6:	0141                	addi	sp,sp,16
				led_toggle(1);	//TX indication
23000fd8:	915ff06f          	j	230008ec <led_toggle>
}
23000fdc:	40b2                	lw	ra,12(sp)
23000fde:	4422                	lw	s0,8(sp)
23000fe0:	4492                	lw	s1,4(sp)
23000fe2:	4902                	lw	s2,0(sp)
23000fe4:	0141                	addi	sp,sp,16
23000fe6:	8082                	ret

23000fe8 <rb_lock>:
  __ASM__ volatile ("csrci mstatus, 8");
23000fe8:	30047073          	csrci	mstatus,8
extern struct device *usb_fs;

static void rb_lock(void)
{
    disable_irq();
}
23000fec:	8082                	ret

23000fee <rb_unlock>:
  __ASM__ volatile ("csrsi mstatus, 8");
23000fee:	30046073          	csrsi	mstatus,8

static void rb_unlock(void)
{
    enable_irq();
}
23000ff2:	8082                	ret

23000ff4 <jtag_write>:

static void jtag_write(uint8_t data)
{
    Ring_Buffer_Write_Byte(&jtag_tx_rb, data);
23000ff4:	85aa                	mv	a1,a0
23000ff6:	42024537          	lui	a0,0x42024
23000ffa:	30050513          	addi	a0,a0,768 # 42024300 <jtag_tx_rb>
23000ffe:	1f30406f          	j	230059f0 <Ring_Buffer_Write_Byte>

23001002 <jtag_ringbuffer_init>:
}

void jtag_ringbuffer_init(void)
{
23001002:	1141                	addi	sp,sp,-16
23001004:	c422                	sw	s0,8(sp)
    memset(jtag_tx_buffer, 0, JTAG_TX_BUFFER_SIZE);
23001006:	40000613          	li	a2,1024
2300100a:	4581                	li	a1,0
2300100c:	00018513          	mv	a0,gp
{
23001010:	c606                	sw	ra,12(sp)
    memset(jtag_tx_buffer, 0, JTAG_TX_BUFFER_SIZE);
23001012:	40b030ef          	jal	ra,23004c1c <memset>
    /* init ring_buffer */
    Ring_Buffer_Init(&jtag_tx_rb, jtag_tx_buffer, JTAG_TX_BUFFER_SIZE, rb_lock, rb_unlock);
23001016:	00018593          	mv	a1,gp
}
2300101a:	4422                	lw	s0,8(sp)
2300101c:	40b2                	lw	ra,12(sp)
    Ring_Buffer_Init(&jtag_tx_rb, jtag_tx_buffer, JTAG_TX_BUFFER_SIZE, rb_lock, rb_unlock);
2300101e:	23001737          	lui	a4,0x23001
23001022:	230016b7          	lui	a3,0x23001
23001026:	42024537          	lui	a0,0x42024
2300102a:	fee70713          	addi	a4,a4,-18 # 23000fee <rb_unlock>
2300102e:	fe868693          	addi	a3,a3,-24 # 23000fe8 <rb_lock>
23001032:	40000613          	li	a2,1024
23001036:	30050513          	addi	a0,a0,768 # 42024300 <jtag_tx_rb>
}
2300103a:	0141                	addi	sp,sp,16
    Ring_Buffer_Init(&jtag_tx_rb, jtag_tx_buffer, JTAG_TX_BUFFER_SIZE, rb_lock, rb_unlock);
2300103c:	7d00406f          	j	2300580c <Ring_Buffer_Init>

23001040 <jtag_gpio_init>:
    };
    PWM_Channel_Init(&pwmCfg);
}
#endif
void jtag_gpio_init(void)
{
23001040:	1141                	addi	sp,sp,-16
    gpio_set_mode(TMS_PIN, GPIO_OUTPUT_MODE);
23001042:	4581                	li	a1,0
23001044:	4509                	li	a0,2
{
23001046:	c606                	sw	ra,12(sp)
    gpio_set_mode(TMS_PIN, GPIO_OUTPUT_MODE);
23001048:	0d9000ef          	jal	ra,23001920 <gpio_set_mode>
    gpio_set_mode(TDI_PIN, GPIO_OUTPUT_MODE);
2300104c:	4581                	li	a1,0
2300104e:	4501                	li	a0,0
23001050:	0d1000ef          	jal	ra,23001920 <gpio_set_mode>
    gpio_set_mode(TCK_PIN, GPIO_OUTPUT_MODE);
23001054:	4581                	li	a1,0
23001056:	453d                	li	a0,15
23001058:	0c9000ef          	jal	ra,23001920 <gpio_set_mode>
    gpio_set_mode(TDO_PIN, GPIO_INPUT_MODE);
2300105c:	458d                	li	a1,3
2300105e:	4505                	li	a0,1
23001060:	0c1000ef          	jal	ra,23001920 <gpio_set_mode>

    TMS_LOW;
23001064:	400007b7          	lui	a5,0x40000
23001068:	1887a703          	lw	a4,392(a5) # 40000188 <__ram_load_addr+0x1cff3264>
    TDI_LOW;
    TCK_LOW;
2300106c:	76e1                	lui	a3,0xffff8
2300106e:	16fd                	addi	a3,a3,-1
    TMS_LOW;
23001070:	9b6d                	andi	a4,a4,-5
23001072:	18e7a423          	sw	a4,392(a5)
    TDI_LOW;
23001076:	1887a703          	lw	a4,392(a5)
#if GOWIN_INT_FLASH_QUIRK 
    pwm_init();
#endif
}
2300107a:	40b2                	lw	ra,12(sp)
    TDI_LOW;
2300107c:	9b79                	andi	a4,a4,-2
2300107e:	18e7a423          	sw	a4,392(a5)
    TCK_LOW;
23001082:	1887a703          	lw	a4,392(a5)
23001086:	8f75                	and	a4,a4,a3
23001088:	18e7a423          	sw	a4,392(a5)
}
2300108c:	0141                	addi	sp,sp,16
2300108e:	8082                	ret

23001090 <usbd_cdc_jtag_out>:
}

#endif

void usbd_cdc_jtag_out(uint8_t ep)
{
23001090:	1101                	addi	sp,sp,-32
23001092:	cc22                	sw	s0,24(sp)
    uint32_t chunk;
    if (!jtag_received_flag)
23001094:	00018413          	mv	s0,gp
23001098:	40042783          	lw	a5,1024(s0)
{
2300109c:	ce06                	sw	ra,28(sp)
    if (!jtag_received_flag)
2300109e:	e395                	bnez	a5,230010c2 <usbd_cdc_jtag_out+0x32>
    {
        usbd_ep_read(ep, jtag_rx_buffer, 64, &chunk);
230010a0:	0074                	addi	a3,sp,12
230010a2:	04000613          	li	a2,64
230010a6:	40440593          	addi	a1,s0,1028
230010aa:	3185                	jal	23000d0a <usbd_ep_read>

        if (chunk == 0)
230010ac:	47b2                	lw	a5,12(sp)
230010ae:	cb91                	beqz	a5,230010c2 <usbd_cdc_jtag_out+0x32>
        {
            //MSG("111\r\n");
            return;
        }
        jtag_rx_len = chunk;
230010b0:	42025737          	lui	a4,0x42025
        // MSG("r:%d\r\n", jtag_rx_len);

        // bflb_platform_dump(jtag_rx_buffer, jtag_rx_len);
        jtag_rx_pos = 0;
230010b4:	44042223          	sw	zero,1092(s0)
        jtag_rx_len = chunk;
230010b8:	42f72c23          	sw	a5,1080(a4) # 42025438 <jtag_rx_len>
        jtag_received_flag = true;
230010bc:	4785                	li	a5,1
230010be:	40f42023          	sw	a5,1024(s0)
    }

}
230010c2:	40f2                	lw	ra,28(sp)
230010c4:	4462                	lw	s0,24(sp)
230010c6:	6105                	addi	sp,sp,32
230010c8:	8082                	ret

230010ca <usbd_cdc_jtag_in>:

extern uint16_t usb_dc_ftdi_send_from_ringbuffer(struct device *dev, Ring_Buffer_Type *rb, uint8_t ep);
void usbd_cdc_jtag_in(uint8_t ep)
{
    if (!jtag_received_flag)
230010ca:	00018793          	mv	a5,gp
230010ce:	4007a783          	lw	a5,1024(a5)
{
230010d2:	862a                	mv	a2,a0
    if (!jtag_received_flag)
230010d4:	eb99                	bnez	a5,230010ea <usbd_cdc_jtag_in+0x20>
    {
        usb_dc_ftdi_send_from_ringbuffer(usb_fs, &jtag_tx_rb, ep);
230010d6:	420257b7          	lui	a5,0x42025
230010da:	4247a503          	lw	a0,1060(a5) # 42025424 <usb_fs>
230010de:	420245b7          	lui	a1,0x42024
230010e2:	30058593          	addi	a1,a1,768 # 42024300 <jtag_tx_rb>
230010e6:	84fff06f          	j	23000934 <usb_dc_ftdi_send_from_ringbuffer>
    }
}
230010ea:	8082                	ret

230010ec <uart_iqr_callback>:
{
    if (state == UART_EVENT_RX_FIFO)
    {

    }
}
230010ec:	8082                	ret

230010ee <board_get_debug_uart_index>:
}

__WEAK__ enum uart_index_type board_get_debug_uart_index(void)
{
    return 0;
}
230010ee:	4501                	li	a0,0
230010f0:	8082                	ret

230010f2 <bflb_platform_printf>:

    enable_irq();
}

void bflb_platform_printf(char *fmt, ...)
{
230010f2:	7131                	addi	sp,sp,-192
230010f4:	cb26                	sw	s1,148(sp)
230010f6:	84aa                	mv	s1,a0
    struct device *uart = device_find("debug_log");
230010f8:	23006537          	lui	a0,0x23006
230010fc:	ba050513          	addi	a0,a0,-1120 # 23005ba0 <ftdi_eeprom_info+0x9c>
{
23001100:	db3e                	sw	a5,180(sp)
23001102:	cf06                	sw	ra,156(sp)
23001104:	cd22                	sw	s0,152(sp)
23001106:	d32e                	sw	a1,164(sp)
23001108:	d532                	sw	a2,168(sp)
2300110a:	d736                	sw	a3,172(sp)
2300110c:	d93a                	sw	a4,176(sp)
2300110e:	dd42                	sw	a6,184(sp)
23001110:	df46                	sw	a7,188(sp)
    struct device *uart = device_find("debug_log");
23001112:	21b030ef          	jal	ra,23004b2c <device_find>
    char print_buf[128];
    va_list ap;

    if(!uart_dbg_disable){
23001116:	420257b7          	lui	a5,0x42025
2300111a:	43c7c783          	lbu	a5,1084(a5) # 4202543c <uart_dbg_disable>
2300111e:	e39d                	bnez	a5,23001144 <bflb_platform_printf+0x52>
        va_start(ap, fmt);
23001120:	1154                	addi	a3,sp,164
        vsnprintf(print_buf, sizeof(print_buf) - 1, fmt, ap);
23001122:	8626                	mv	a2,s1
23001124:	07f00593          	li	a1,127
23001128:	842a                	mv	s0,a0
2300112a:	0808                	addi	a0,sp,16
        va_start(ap, fmt);
2300112c:	c636                	sw	a3,12(sp)
        vsnprintf(print_buf, sizeof(print_buf) - 1, fmt, ap);
2300112e:	363030ef          	jal	ra,23004c90 <vsnprintf>
        va_end(ap);

        device_write(uart, 0, (uint8_t *)print_buf, strlen(print_buf));
23001132:	0808                	addi	a0,sp,16
23001134:	2fb030ef          	jal	ra,23004c2e <strlen>
23001138:	86aa                	mv	a3,a0
2300113a:	0810                	addi	a2,sp,16
2300113c:	4581                	li	a1,0
2300113e:	8522                	mv	a0,s0
23001140:	291030ef          	jal	ra,23004bd0 <device_write>
    }
}
23001144:	40fa                	lw	ra,156(sp)
23001146:	446a                	lw	s0,152(sp)
23001148:	44da                	lw	s1,148(sp)
2300114a:	6129                	addi	sp,sp,192
2300114c:	8082                	ret

2300114e <bflb_platform_init>:
{
2300114e:	1141                	addi	sp,sp,-16
23001150:	c606                	sw	ra,12(sp)
23001152:	c422                	sw	s0,8(sp)
  __ASM__ volatile ("csrci mstatus, 8");
23001154:	30047073          	csrci	mstatus,8
    board_init();
23001158:	20d5                	jal	2300123c <board_init>
    if(!uart_dbg_disable){
2300115a:	420257b7          	lui	a5,0x42025
2300115e:	43c7c783          	lbu	a5,1084(a5) # 4202543c <uart_dbg_disable>
23001162:	ef9d                	bnez	a5,230011a0 <bflb_platform_init+0x52>
        uart_register(board_get_debug_uart_index(), "debug_log", DEVICE_OFLAG_RDWR);
23001164:	3769                	jal	230010ee <board_get_debug_uart_index>
23001166:	23006437          	lui	s0,0x23006
2300116a:	ba040593          	addi	a1,s0,-1120 # 23005ba0 <ftdi_eeprom_info+0x9c>
2300116e:	660d                	lui	a2,0x3
23001170:	4bf000ef          	jal	ra,23001e2e <uart_register>
        struct device *uart = device_find("debug_log");
23001174:	ba040513          	addi	a0,s0,-1120
23001178:	1b5030ef          	jal	ra,23004b2c <device_find>
2300117c:	842a                	mv	s0,a0
        if (uart)
2300117e:	c105                	beqz	a0,2300119e <bflb_platform_init+0x50>
            device_open(uart, DEVICE_OFLAG_STREAM_TX | DEVICE_OFLAG_INT_RX);
23001180:	45a5                	li	a1,9
23001182:	1f1030ef          	jal	ra,23004b72 <device_open>
            device_set_callback(uart, uart_iqr_callback);
23001186:	230015b7          	lui	a1,0x23001
2300118a:	0ec58593          	addi	a1,a1,236 # 230010ec <uart_iqr_callback>
2300118e:	8522                	mv	a0,s0
23001190:	25d030ef          	jal	ra,23004bec <device_set_callback>
            device_control(uart, DEVICE_CTRL_SET_INT, (void *)(UART_RX_FIFO_IT));
23001194:	4621                	li	a2,8
23001196:	4585                	li	a1,1
23001198:	8522                	mv	a0,s0
2300119a:	21f030ef          	jal	ra,23004bb8 <device_control>
        bl_show_info();
2300119e:	2035                	jal	230011ca <bl_show_info>
    if (!mmheap_init_with_pool(&_HeapBase, (size_t)&_HeapSize))
230011a0:	6585                	lui	a1,0x1
230011a2:	4201e537          	lui	a0,0x4201e
230011a6:	00058593          	mv	a1,a1
230011aa:	00050513          	mv	a0,a0
230011ae:	590040ef          	jal	ra,2300573e <mmheap_init_with_pool>
230011b2:	c511                	beqz	a0,230011be <bflb_platform_init+0x70>
        MSG("dynamic memory init error\r\n");
230011b4:	23006537          	lui	a0,0x23006
230011b8:	b8450513          	addi	a0,a0,-1148 # 23005b84 <ftdi_eeprom_info+0x80>
230011bc:	3f1d                	jal	230010f2 <bflb_platform_printf>
  __ASM__ volatile ("csrsi mstatus, 8");
230011be:	30046073          	csrsi	mstatus,8
}
230011c2:	40b2                	lw	ra,12(sp)
230011c4:	4422                	lw	s0,8(sp)
230011c6:	0141                	addi	sp,sp,16
230011c8:	8082                	ret

230011ca <bl_show_info>:
    peripheral_clock_init();
}

void bl_show_info(void)
{
	MSG(" _____ ___________ _____ ___________ \r\n");
230011ca:	23006537          	lui	a0,0x23006
{
230011ce:	1141                	addi	sp,sp,-16
	MSG(" _____ ___________ _____ ___________ \r\n");
230011d0:	c4450513          	addi	a0,a0,-956 # 23005c44 <af_pin_table+0x98>
{
230011d4:	c606                	sw	ra,12(sp)
	MSG(" _____ ___________ _____ ___________ \r\n");
230011d6:	3f31                	jal	230010f2 <bflb_platform_printf>
	MSG("/  ___|_   _| ___ \\  ___|  ___|  _  \\ \r\n");
230011d8:	23006537          	lui	a0,0x23006
230011dc:	c6c50513          	addi	a0,a0,-916 # 23005c6c <af_pin_table+0xc0>
230011e0:	3f09                	jal	230010f2 <bflb_platform_printf>
	MSG("\\ `--.  | | | |_/ / |__ | |__ | | | |\r\n");
230011e2:	23006537          	lui	a0,0x23006
230011e6:	c9850513          	addi	a0,a0,-872 # 23005c98 <af_pin_table+0xec>
230011ea:	3721                	jal	230010f2 <bflb_platform_printf>
	MSG(" `--. \\ | | |  __/|  __||  __|| | | |\r\n");
230011ec:	23006537          	lui	a0,0x23006
230011f0:	cc050513          	addi	a0,a0,-832 # 23005cc0 <af_pin_table+0x114>
230011f4:	3dfd                	jal	230010f2 <bflb_platform_printf>
	MSG("/\\__/ /_| |_| |   | |___| |___| |/ / \r\n");
230011f6:	23006537          	lui	a0,0x23006
230011fa:	ce850513          	addi	a0,a0,-792 # 23005ce8 <af_pin_table+0x13c>
230011fe:	3dd5                	jal	230010f2 <bflb_platform_printf>
	MSG("\\____/ \\___/\\_|   \\____/\\____/|___/  \r\n");
23001200:	23006537          	lui	a0,0x23006
23001204:	d1050513          	addi	a0,a0,-752 # 23005d10 <af_pin_table+0x164>
23001208:	35ed                	jal	230010f2 <bflb_platform_printf>
    MSG("\r\n");
2300120a:	23006537          	lui	a0,0x23006
2300120e:	fcc50513          	addi	a0,a0,-52 # 23005fcc <af_pin_table+0x420>
23001212:	35c5                	jal	230010f2 <bflb_platform_printf>
    MSG("Build:%s,%s\r\n",__TIME__,__DATE__);
23001214:	23006637          	lui	a2,0x23006
23001218:	230065b7          	lui	a1,0x23006
2300121c:	23006537          	lui	a0,0x23006
23001220:	d5050513          	addi	a0,a0,-688 # 23005d50 <af_pin_table+0x1a4>
23001224:	d3860613          	addi	a2,a2,-712 # 23005d38 <af_pin_table+0x18c>
23001228:	d4458593          	addi	a1,a1,-700 # 23005d44 <af_pin_table+0x198>
2300122c:	35d9                	jal	230010f2 <bflb_platform_printf>

    MSG("uart clock:%dM\r\n",peripheral_clock_get(PERIPHERAL_CLOCK_UART)/1000000);
    MSG("spi clock:%dM\r\n",peripheral_clock_get(PERIPHERAL_CLOCK_SPI)/1000000);
    MSG("i2c clock:%dM\r\n",peripheral_clock_get(PERIPHERAL_CLOCK_I2C)/1000000);
#endif
}
2300122e:	40b2                	lw	ra,12(sp)
    MSG("Copyright (c) 2021 Sipeed team\r\n");
23001230:	23006537          	lui	a0,0x23006
23001234:	d6050513          	addi	a0,a0,-672 # 23005d60 <af_pin_table+0x1b4>
}
23001238:	0141                	addi	sp,sp,16
    MSG("Copyright (c) 2021 Sipeed team\r\n");
2300123a:	bd65                	j	230010f2 <bflb_platform_printf>

2300123c <board_init>:

void board_init(void)
{
2300123c:	7139                	addi	sp,sp,-64
2300123e:	de06                	sw	ra,60(sp)
23001240:	dc22                	sw	s0,56(sp)
23001242:	da26                	sw	s1,52(sp)
23001244:	d84a                	sw	s2,48(sp)
23001246:	d64e                	sw	s3,44(sp)
23001248:	d452                	sw	s4,40(sp)
2300124a:	d256                	sw	s5,36(sp)
2300124c:	d05a                	sw	s6,32(sp)
2300124e:	ce5e                	sw	s7,28(sp)
23001250:	cc62                	sw	s8,24(sp)
    system_clock_init();
23001252:	20cd                	jal	23001334 <system_clock_init>
    peripheral_clock_init();
23001254:	2a05                	jal	23001384 <peripheral_clock_init>
    gpio_cfg.pullType = GPIO_PULL_UP;
23001256:	23006437          	lui	s0,0x23006
    gpio_cfg.gpioMode = GPIO_MODE_AF;
2300125a:	4789                	li	a5,2
2300125c:	00f11523          	sh	a5,10(sp)
23001260:	bac40413          	addi	s0,s0,-1108 # 23005bac <af_pin_table>
    gpio_cfg.drive = 0;
23001264:	10000793          	li	a5,256
23001268:	00f11623          	sh	a5,12(sp)
    for (int i = 0; i < sizeof(af_pin_table)/sizeof(af_pin_table[0]); i++)
2300126c:	09840493          	addi	s1,s0,152
        if(af_pin_table[i].func == GPIO_FUN_UNUSED)
23001270:	0ff00913          	li	s2,255
        else if(af_pin_table[i].func == GPIO_FUN_PWM)
23001274:	49a1                	li	s3,8
        else if((af_pin_table[i].func == GPIO_FUN_DAC)|| (af_pin_table[i].func == GPIO_FUN_DAC))
23001276:	0a000a13          	li	s4,160
        else if((af_pin_table[i].func & 0x70) == 0x70)
2300127a:	07000a93          	li	s5,112
            gpio_cfg.gpioFun = GPIO_FUN_UART;
2300127e:	4b1d                	li	s6,7
            if (gpio_cfg.gpioPin > 31)
23001280:	4bfd                	li	s7,31
            gpio_cfg.gpioFun  = GPIO_FUN_ANALOG;
23001282:	4c29                	li	s8,10
        gpio_cfg.gpioFun = af_pin_table[i].func;
23001284:	00245783          	lhu	a5,2(s0)
        gpio_cfg.gpioPin = af_pin_table[i].pin;
23001288:	00044503          	lbu	a0,0(s0)
        gpio_cfg.gpioFun = af_pin_table[i].func;
2300128c:	0ff7f593          	andi	a1,a5,255
        gpio_cfg.gpioPin = af_pin_table[i].pin;
23001290:	00a10423          	sb	a0,8(sp)
        gpio_cfg.gpioFun = af_pin_table[i].func;
23001294:	00b104a3          	sb	a1,9(sp)
        if(af_pin_table[i].func == GPIO_FUN_UNUSED)
23001298:	01278c63          	beq	a5,s2,230012b0 <board_init+0x74>
        else if(af_pin_table[i].func == GPIO_FUN_PWM)
2300129c:	03379963          	bne	a5,s3,230012ce <board_init+0x92>
            gpio_cfg.pullType = GPIO_PULL_DOWN;
230012a0:	4785                	li	a5,1
230012a2:	00f105a3          	sb	a5,11(sp)
        GLB_GPIO_Init(&gpio_cfg);
230012a6:	0028                	addi	a0,sp,8
230012a8:	ff014097          	auipc	ra,0xff014
230012ac:	0e8080e7          	jalr	232(ra) # 22015390 <GLB_GPIO_Init>
    for (int i = 0; i < sizeof(af_pin_table)/sizeof(af_pin_table[0]); i++)
230012b0:	0411                	addi	s0,s0,4
230012b2:	fc9419e3          	bne	s0,s1,23001284 <board_init+0x48>
    board_clock_init();
    board_pin_mux_init();
230012b6:	50f2                	lw	ra,60(sp)
230012b8:	5462                	lw	s0,56(sp)
230012ba:	54d2                	lw	s1,52(sp)
230012bc:	5942                	lw	s2,48(sp)
230012be:	59b2                	lw	s3,44(sp)
230012c0:	5a22                	lw	s4,40(sp)
230012c2:	5a92                	lw	s5,36(sp)
230012c4:	5b02                	lw	s6,32(sp)
230012c6:	4bf2                	lw	s7,28(sp)
230012c8:	4c62                	lw	s8,24(sp)
230012ca:	6121                	addi	sp,sp,64
230012cc:	8082                	ret
        else if((af_pin_table[i].func == GPIO_FUN_DAC)|| (af_pin_table[i].func == GPIO_FUN_DAC))
230012ce:	01479863          	bne	a5,s4,230012de <board_init+0xa2>
            gpio_cfg.gpioMode = GPIO_MODE_ANALOG;
230012d2:	478d                	li	a5,3
            gpio_cfg.gpioFun  = GPIO_FUN_ANALOG;
230012d4:	018104a3          	sb	s8,9(sp)
            gpio_cfg.gpioMode = GPIO_MODE_ANALOG;
230012d8:	00f10523          	sb	a5,10(sp)
230012dc:	b7e9                	j	230012a6 <board_init+0x6a>
        else if((af_pin_table[i].func & 0x70) == 0x70)
230012de:	0707f793          	andi	a5,a5,112
230012e2:	fd5792e3          	bne	a5,s5,230012a6 <board_init+0x6a>
            gpio_cfg.gpioFun = GPIO_FUN_UART;
230012e6:	016104a3          	sb	s6,9(sp)
            uint8_t sig = af_pin_table[i].func & 0x07;
230012ea:	899d                	andi	a1,a1,7
            if (gpio_cfg.gpioPin > 31)
230012ec:	00abf363          	bgeu	s7,a0,230012f2 <board_init+0xb6>
                GLB_UART_Fun_Sel(((gpio_cfg.gpioPin-9) % 8), sig);
230012f0:	155d                	addi	a0,a0,-9
                GLB_UART_Fun_Sel((gpio_cfg.gpioPin % 8), sig);
230012f2:	891d                	andi	a0,a0,7
230012f4:	4c7010ef          	jal	ra,23002fba <GLB_UART_Fun_Sel>
230012f8:	b77d                	j	230012a6 <board_init+0x6a>

230012fa <system_clock_get.part.0>:
    case SYSTEM_CLOCK_ROOT_CLOCK:
        return SystemCoreClockGet();
    case SYSTEM_CLOCK_FCLK:
        return (SystemCoreClockGet()/(GLB_Get_HCLK_Div()+1)); 
    case SYSTEM_CLOCK_BCLK:
        return (SystemCoreClockGet()/((GLB_Get_HCLK_Div()+1)*(GLB_Get_BCLK_Div()+1)));
230012fa:	4000f7b7          	lui	a5,0x4000f
uint32_t system_clock_get(enum system_clock_type type)
230012fe:	1141                	addi	sp,sp,-16
23001300:	c606                	sw	ra,12(sp)
23001302:	c422                	sw	s0,8(sp)
23001304:	c226                	sw	s1,4(sp)
        return (SystemCoreClockGet()/((GLB_Get_HCLK_Div()+1)*(GLB_Get_BCLK_Div()+1)));
23001306:	1087a483          	lw	s1,264(a5) # 4000f108 <__ram_load_addr+0x1d0021e4>
2300130a:	ff015097          	auipc	ra,0xff015
2300130e:	ee4080e7          	jalr	-284(ra) # 220161ee <GLB_Get_HCLK_Div>
23001312:	842a                	mv	s0,a0
23001314:	ff015097          	auipc	ra,0xff015
23001318:	ed0080e7          	jalr	-304(ra) # 220161e4 <GLB_Get_BCLK_Div>
2300131c:	0505                	addi	a0,a0,1
2300131e:	00140793          	addi	a5,s0,1
23001322:	02a78533          	mul	a0,a5,a0
#endif
    default:
        break;
    }
    return 0;
}
23001326:	40b2                	lw	ra,12(sp)
23001328:	4422                	lw	s0,8(sp)
2300132a:	02a4d533          	divu	a0,s1,a0
2300132e:	4492                	lw	s1,4(sp)
23001330:	0141                	addi	sp,sp,16
23001332:	8082                	ret

23001334 <system_clock_init>:
{
23001334:	1141                	addi	sp,sp,-16
    GLB_Set_System_CLK(CLOCK_XTAL,BSP_ROOT_CLOCK_SOURCE-2);
23001336:	4591                	li	a1,4
23001338:	4505                	li	a0,1
{
2300133a:	c606                	sw	ra,12(sp)
2300133c:	c422                	sw	s0,8(sp)
    GLB_Set_System_CLK(CLOCK_XTAL,BSP_ROOT_CLOCK_SOURCE-2);
2300133e:	ff015097          	auipc	ra,0xff015
23001342:	ec4080e7          	jalr	-316(ra) # 22016202 <GLB_Set_System_CLK>
    GLB_Set_System_CLK_Div(BSP_HCLK_DIV,BSP_BCLK_DIV);
23001346:	4585                	li	a1,1
23001348:	4501                	li	a0,0
2300134a:	ff015097          	auipc	ra,0xff015
2300134e:	e90080e7          	jalr	-368(ra) # 220161da <GLB_Set_System_CLK_Div>
    return ((SystemCoreClockGet()/(GLB_Get_BCLK_Div() + 1))/1000/1000-1);
23001352:	4000f7b7          	lui	a5,0x4000f
23001356:	1087a403          	lw	s0,264(a5) # 4000f108 <__ram_load_addr+0x1d0021e4>
2300135a:	ff015097          	auipc	ra,0xff015
2300135e:	e8a080e7          	jalr	-374(ra) # 220161e4 <GLB_Get_BCLK_Div>
23001362:	0505                	addi	a0,a0,1
23001364:	02a45433          	divu	s0,s0,a0
23001368:	000f4637          	lui	a2,0xf4
2300136c:	24060613          	addi	a2,a2,576 # f4240 <HeapSize+0xf3240>
}
23001370:	40b2                	lw	ra,12(sp)
    GLB_Set_MTimer_CLK(1, GLB_MTIMER_CLK_BCLK, mtimer_get_clk_src_div());
23001372:	4581                	li	a1,0
23001374:	4505                	li	a0,1
    return ((SystemCoreClockGet()/(GLB_Get_BCLK_Div() + 1))/1000/1000-1);
23001376:	02c45633          	divu	a2,s0,a2
}
2300137a:	4422                	lw	s0,8(sp)
2300137c:	0141                	addi	sp,sp,16
    GLB_Set_MTimer_CLK(1, GLB_MTIMER_CLK_BCLK, mtimer_get_clk_src_div());
2300137e:	167d                	addi	a2,a2,-1
23001380:	3f10106f          	j	23002f70 <GLB_Set_MTimer_CLK>

23001384 <peripheral_clock_init>:
{
23001384:	1141                	addi	sp,sp,-16
    GLB_Set_UART_CLK(ENABLE,HBN_UART_CLK_96M,BSP_UART_CLOCK_DIV);
23001386:	4601                	li	a2,0
23001388:	4585                	li	a1,1
2300138a:	4505                	li	a0,1
{
2300138c:	c606                	sw	ra,12(sp)
    GLB_Set_UART_CLK(ENABLE,HBN_UART_CLK_96M,BSP_UART_CLOCK_DIV);
2300138e:	309010ef          	jal	ra,23002e96 <GLB_Set_UART_CLK>
}
23001392:	40b2                	lw	ra,12(sp)
    GLB_Set_USB_CLK(1);
23001394:	4505                	li	a0,1
}
23001396:	0141                	addi	sp,sp,16
    GLB_Set_USB_CLK(1);
23001398:	2dd0106f          	j	23002e74 <GLB_Set_USB_CLK>

2300139c <peripheral_clock_get>:
uint32_t peripheral_clock_get(enum peripheral_clock_type type)
{
    uint32_t tmpVal;
    uint32_t div;
    switch (type)
2300139c:	4799                	li	a5,6
2300139e:	02a7e363          	bltu	a5,a0,230013c4 <peripheral_clock_get+0x28>
230013a2:	4785                	li	a5,1
230013a4:	00a797b3          	sll	a5,a5,a0
230013a8:	0587f713          	andi	a4,a5,88
230013ac:	eb19                	bnez	a4,230013c2 <peripheral_clock_get+0x26>
230013ae:	0267f793          	andi	a5,a5,38
230013b2:	eb89                	bnez	a5,230013c4 <peripheral_clock_get+0x28>
230013b4:	e509                	bnez	a0,230013be <peripheral_clock_get+0x22>
    {
    case PERIPHERAL_CLOCK_UART:
    #if defined(BSP_USING_UART0)||defined(BSP_USING_UART1)
    #if BSP_UART_CLOCK_SOURCE == ROOT_CLOCK_SOURCE_PLL_96M
        return 96000000;
230013b6:	05b8e7b7          	lui	a5,0x5b8e
230013ba:	80078793          	addi	a5,a5,-2048 # 5b8d800 <HeapSize+0x5b8c800>
    }
    
    (void)(tmpVal);
    (void)(div);
    return 0;
230013be:	853e                	mv	a0,a5
230013c0:	8082                	ret
    switch (type)
230013c2:	bf25                	j	230012fa <system_clock_get.part.0>
    return 0;
230013c4:	4781                	li	a5,0
230013c6:	bfe5                	j	230013be <peripheral_clock_get+0x22>

230013c8 <dma_close>:
 * 
 * @param dev 
 * @return int 
 */
int dma_close(struct device *dev)
{
230013c8:	1141                	addi	sp,sp,-16
230013ca:	c606                	sw	ra,12(sp)
    DMA_Disable();
230013cc:	0d9010ef          	jal	ra,23002ca4 <DMA_Disable>
    return 0;
}
230013d0:	40b2                	lw	ra,12(sp)
230013d2:	4501                	li	a0,0
230013d4:	0141                	addi	sp,sp,16
230013d6:	8082                	ret

230013d8 <dma_open>:
{
230013d8:	1101                	addi	sp,sp,-32
230013da:	ce06                	sw	ra,28(sp)
230013dc:	cc22                	sw	s0,24(sp)
230013de:	842a                	mv	s0,a0
    DMA_IntMask(dma_device->ch, DMA_INT_ALL, MASK);
230013e0:	03554503          	lbu	a0,53(a0)
230013e4:	4605                	li	a2,1
230013e6:	4589                	li	a1,2
    DMA_LLI_Cfg_Type lliCfg = {0};
230013e8:	00011623          	sh	zero,12(sp)
230013ec:	00010723          	sb	zero,14(sp)
    DMA_IntMask(dma_device->ch, DMA_INT_ALL, MASK);
230013f0:	163010ef          	jal	ra,23002d52 <DMA_IntMask>
    NVIC_DisableIRQ(DMA_ALL_IRQn);
230013f4:	457d                	li	a0,31
230013f6:	598010ef          	jal	ra,2300298e <clic_disable_interrupt>
    DMA_Disable();
230013fa:	0ab010ef          	jal	ra,23002ca4 <DMA_Disable>
    DMA_Channel_Disable(dma_device->ch);
230013fe:	03544503          	lbu	a0,53(s0)
23001402:	0d7010ef          	jal	ra,23002cd8 <DMA_Channel_Disable>
    lliCfg.dir = dma_device->direction;
23001406:	03644783          	lbu	a5,54(s0)
    DMA_LLI_Init(dma_device->ch, &lliCfg);
2300140a:	03544503          	lbu	a0,53(s0)
2300140e:	006c                	addi	a1,sp,12
    lliCfg.dir = dma_device->direction;
23001410:	00f10623          	sb	a5,12(sp)
    lliCfg.srcPeriph = dma_device->src_req;
23001414:	5c1c                	lw	a5,56(s0)
23001416:	00f106a3          	sb	a5,13(sp)
    lliCfg.dstPeriph = dma_device->dst_req;
2300141a:	5c5c                	lw	a5,60(s0)
2300141c:	00f10723          	sb	a5,14(sp)
    DMA_LLI_Init(dma_device->ch, &lliCfg);
23001420:	0cd010ef          	jal	ra,23002cec <DMA_LLI_Init>
    dma_ctrl_cfg.bits.dst_min_mode = 0;
23001424:	420257b7          	lui	a5,0x42025
23001428:	44078793          	addi	a5,a5,1088 # 42025440 <dma_ctrl_cfg>
2300142c:	4398                	lw	a4,0(a5)
2300142e:	fe7dc6b7          	lui	a3,0xfe7dc
23001432:	16fd                	addi	a3,a3,-1
23001434:	8f75                	and	a4,a4,a3
23001436:	c398                	sw	a4,0(a5)
    DMA_Enable();
23001438:	055010ef          	jal	ra,23002c8c <DMA_Enable>
    Interrupt_Handler_Register(DMA_ALL_IRQn, DMA0_IRQ);
2300143c:	230025b7          	lui	a1,0x23002
23001440:	457d                	li	a0,31
23001442:	8a258593          	addi	a1,a1,-1886 # 230018a2 <DMA0_IRQ>
23001446:	708010ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
}
2300144a:	4462                	lw	s0,24(sp)
2300144c:	40f2                	lw	ra,28(sp)
2300144e:	4501                	li	a0,0
23001450:	6105                	addi	sp,sp,32
23001452:	8082                	ret

23001454 <dma_control>:
    switch (cmd)
23001454:	fff58793          	addi	a5,a1,-1
23001458:	4749                	li	a4,18
2300145a:	0af76763          	bltu	a4,a5,23001508 <dma_control+0xb4>
2300145e:	23006737          	lui	a4,0x23006
23001462:	078a                	slli	a5,a5,0x2
23001464:	d8470713          	addi	a4,a4,-636 # 23005d84 <af_pin_table+0x1d8>
23001468:	97ba                	add	a5,a5,a4
2300146a:	439c                	lw	a5,0(a5)
{
2300146c:	1101                	addi	sp,sp,-32
2300146e:	cc22                	sw	s0,24(sp)
23001470:	ce06                	sw	ra,28(sp)
23001472:	85b2                	mv	a1,a2
23001474:	842a                	mv	s0,a0
    switch (cmd)
23001476:	8782                	jr	a5
            DMA_IntMask(dma_device->ch, DMA_INT_TCOMPLETED, UNMASK);
23001478:	03554503          	lbu	a0,53(a0)
2300147c:	4601                	li	a2,0
2300147e:	4581                	li	a1,0
23001480:	0d3010ef          	jal	ra,23002d52 <DMA_IntMask>
            DMA_IntMask(dma_device->ch, DMA_INT_ERR, UNMASK);
23001484:	03544503          	lbu	a0,53(s0)
23001488:	4601                	li	a2,0
2300148a:	4585                	li	a1,1
2300148c:	0c7010ef          	jal	ra,23002d52 <DMA_IntMask>
            NVIC_EnableIRQ(DMA_ALL_IRQn);
23001490:	457d                	li	a0,31
23001492:	4ea010ef          	jal	ra,2300297c <clic_enable_interrupt>
    return 0;
23001496:	4501                	li	a0,0
23001498:	a891                	j	230014ec <dma_control+0x98>
            DMA_IntMask(dma_device->ch, DMA_INT_TCOMPLETED, MASK);
2300149a:	03554503          	lbu	a0,53(a0)
2300149e:	4605                	li	a2,1
230014a0:	4581                	li	a1,0
230014a2:	0b1010ef          	jal	ra,23002d52 <DMA_IntMask>
            DMA_IntMask(dma_device->ch, DMA_INT_ERR, MASK);
230014a6:	03544503          	lbu	a0,53(s0)
230014aa:	4605                	li	a2,1
230014ac:	4585                	li	a1,1
230014ae:	0a5010ef          	jal	ra,23002d52 <DMA_IntMask>
            NVIC_DisableIRQ(DMA_ALL_IRQn);
230014b2:	457d                	li	a0,31
230014b4:	4da010ef          	jal	ra,2300298e <clic_disable_interrupt>
            break;
230014b8:	bff9                	j	23001496 <dma_control+0x42>
            lliCfg.dir = cfg->direction;
230014ba:	00064783          	lbu	a5,0(a2)
            DMA_LLI_Init(dma_device->ch, &lliCfg);
230014be:	03554503          	lbu	a0,53(a0)
230014c2:	006c                	addi	a1,sp,12
            lliCfg.dir = cfg->direction;
230014c4:	00f10623          	sb	a5,12(sp)
            lliCfg.srcPeriph = cfg->src_req;
230014c8:	425c                	lw	a5,4(a2)
230014ca:	00f106a3          	sb	a5,13(sp)
            lliCfg.dstPeriph = cfg->dst_req;
230014ce:	461c                	lw	a5,8(a2)
230014d0:	00f10723          	sb	a5,14(sp)
            DMA_LLI_Init(dma_device->ch, &lliCfg);
230014d4:	019010ef          	jal	ra,23002cec <DMA_LLI_Init>
            break;
230014d8:	bf7d                	j	23001496 <dma_control+0x42>
            DMA_LLI_Update(dma_device->ch, (uint32_t)args);
230014da:	03554503          	lbu	a0,53(a0)
230014de:	05f010ef          	jal	ra,23002d3c <DMA_LLI_Update>
            break;
230014e2:	bf55                	j	23001496 <dma_control+0x42>
            return DMA_Channel_Is_Busy(dma_device->ch);
230014e4:	03554503          	lbu	a0,53(a0)
230014e8:	7c8010ef          	jal	ra,23002cb0 <DMA_Channel_Is_Busy>
}
230014ec:	40f2                	lw	ra,28(sp)
230014ee:	4462                	lw	s0,24(sp)
230014f0:	6105                	addi	sp,sp,32
230014f2:	8082                	ret
            DMA_Channel_Enable(dma_device->ch);
230014f4:	03554503          	lbu	a0,53(a0)
230014f8:	7ca010ef          	jal	ra,23002cc2 <DMA_Channel_Enable>
            break;
230014fc:	bf69                	j	23001496 <dma_control+0x42>
            DMA_Channel_Disable(dma_device->ch);
230014fe:	03554503          	lbu	a0,53(a0)
23001502:	7d6010ef          	jal	ra,23002cd8 <DMA_Channel_Disable>
            break;
23001506:	bf41                	j	23001496 <dma_control+0x42>
    return 0;
23001508:	4501                	li	a0,0
}
2300150a:	8082                	ret

2300150c <dma_register>:
    if (DMA_MAX_INDEX == 0)
        return -DEVICE_EINVAL;

    dev = &(dmax_device[index].parent);

    dev->open = dma_open;
2300150c:	04800793          	li	a5,72
23001510:	02f507b3          	mul	a5,a0,a5
23001514:	42024537          	lui	a0,0x42024
23001518:	0f450513          	addi	a0,a0,244 # 420240f4 <dmax_device>
2300151c:	953e                	add	a0,a0,a5
2300151e:	230017b7          	lui	a5,0x23001
23001522:	3d878793          	addi	a5,a5,984 # 230013d8 <dma_open>
23001526:	cd1c                	sw	a5,24(a0)
    dev->close = dma_close;
23001528:	230017b7          	lui	a5,0x23001
2300152c:	3c878793          	addi	a5,a5,968 # 230013c8 <dma_close>
23001530:	cd5c                	sw	a5,28(a0)
    dev->control = dma_control;
23001532:	230017b7          	lui	a5,0x23001
23001536:	45478793          	addi	a5,a5,1108 # 23001454 <dma_control>
2300153a:	d11c                	sw	a5,32(a0)
    // dev->write = dma_write;
    // dev->read = dma_read;

    dev->status = DEVICE_UNREGISTER;
2300153c:	60000793          	li	a5,1536
23001540:	00f51a23          	sh	a5,20(a0)
    dev->type = DEVICE_CLASS_DMA;
    dev->handle = NULL;
23001544:	02052823          	sw	zero,48(a0)

    return device_register(dev, name, flag);
23001548:	5980306f          	j	23004ae0 <device_register>

2300154c <dma_reload>:
 * @param dst_addr 
 * @param transfer_size 
 * @return int 
 */
int dma_reload(struct device *dev, uint32_t src_addr, uint32_t dst_addr, uint32_t transfer_size)
{
2300154c:	715d                	addi	sp,sp,-80
2300154e:	c4a2                	sw	s0,72(sp)
23001550:	c2a6                	sw	s1,68(sp)
23001552:	c0ca                	sw	s2,64(sp)
23001554:	de4e                	sw	s3,60(sp)
23001556:	da56                	sw	s5,52(sp)
23001558:	d462                	sw	s8,40(sp)
2300155a:	c686                	sw	ra,76(sp)
2300155c:	dc52                	sw	s4,56(sp)
2300155e:	d85a                	sw	s6,48(sp)
23001560:	d65e                	sw	s7,44(sp)
23001562:	d266                	sw	s9,36(sp)
23001564:	d06a                	sw	s10,32(sp)
23001566:	ce6e                	sw	s11,28(sp)
23001568:	8aaa                	mv	s5,a0
    uint32_t actual_transfer_len = 0;
    uint32_t actual_transfer_offset = 0;

    dma_device_t *dma_device = (dma_device_t *)dev;

    DMA_Channel_Disable(dma_device->ch);
2300156a:	03554503          	lbu	a0,53(a0)
{
2300156e:	84ae                	mv	s1,a1
23001570:	8932                	mv	s2,a2
23001572:	8c36                	mv	s8,a3
    DMA_Channel_Disable(dma_device->ch);
23001574:	764010ef          	jal	ra,23002cd8 <DMA_Channel_Disable>

    if (dma_device->direction == DMA_MEMORY_TO_MEMORY)
23001578:	420259b7          	lui	s3,0x42025
2300157c:	036ac783          	lbu	a5,54(s5)
23001580:	44098413          	addi	s0,s3,1088 # 42025440 <dma_ctrl_cfg>
23001584:	10079963          	bnez	a5,23001696 <dma_reload+0x14a>
    {
        dma_ctrl_cfg.bits.SI = 1;
23001588:	00344783          	lbu	a5,3(s0)
2300158c:	9bcd                	andi	a5,a5,-13
2300158e:	00c7e793          	ori	a5,a5,12
        dma_ctrl_cfg.bits.SI = 0;
        dma_ctrl_cfg.bits.DI = 1;
    }
    else if (dma_device->direction == DMA_PERIPH_TO_PERIPH)
    {
        dma_ctrl_cfg.bits.SI = 0;
23001592:	00f401a3          	sb	a5,3(s0)
        dma_ctrl_cfg.bits.DI = 0;
    }

    dma_ctrl_cfg.bits.SBSize = dma_device->src_burst_size;
23001596:	040ac603          	lbu	a2,64(s5)
2300159a:	77f5                	lui	a5,0xffffd
2300159c:	17fd                	addi	a5,a5,-1
2300159e:	8a0d                	andi	a2,a2,3
230015a0:	00c61713          	slli	a4,a2,0xc
230015a4:	4010                	lw	a2,0(s0)
230015a6:	8e7d                	and	a2,a2,a5
230015a8:	8e59                	or	a2,a2,a4
230015aa:	c010                	sw	a2,0(s0)
    dma_ctrl_cfg.bits.DBSize = dma_device->dst_burst_size;
230015ac:	041ac703          	lbu	a4,65(s5)
230015b0:	8b0d                	andi	a4,a4,3
230015b2:	00f71793          	slli	a5,a4,0xf
230015b6:	7721                	lui	a4,0xfffe8
230015b8:	177d                	addi	a4,a4,-1
230015ba:	8f71                	and	a4,a4,a2
230015bc:	8f5d                	or	a4,a4,a5
230015be:	c018                	sw	a4,0(s0)
    dma_ctrl_cfg.bits.SWidth = dma_device->src_width;
230015c0:	042ac683          	lbu	a3,66(s5)
230015c4:	0036f793          	andi	a5,a3,3
230015c8:	01279613          	slli	a2,a5,0x12
230015cc:	fff407b7          	lui	a5,0xfff40
230015d0:	17fd                	addi	a5,a5,-1
230015d2:	8ff9                	and	a5,a5,a4
230015d4:	8fd1                	or	a5,a5,a2
230015d6:	c01c                	sw	a5,0(s0)
    dma_ctrl_cfg.bits.DWidth = dma_device->dst_width;
230015d8:	043ac703          	lbu	a4,67(s5)
230015dc:	ffa00637          	lui	a2,0xffa00
230015e0:	167d                	addi	a2,a2,-1
230015e2:	8b0d                	andi	a4,a4,3
230015e4:	0756                	slli	a4,a4,0x15
230015e6:	8ff1                	and	a5,a5,a2
230015e8:	8fd9                	or	a5,a5,a4
230015ea:	c01c                	sw	a5,0(s0)

    if (dma_device->src_width == DMA_TRANSFER_WIDTH_8BIT)
230015ec:	0e068a63          	beqz	a3,230016e0 <dma_reload+0x194>
    {
        actual_transfer_offset = 4095;
        actual_transfer_len = transfer_size;
    }
    else if (dma_device->src_width == DMA_TRANSFER_WIDTH_16BIT)
230015f0:	4785                	li	a5,1
230015f2:	0cf69b63          	bne	a3,a5,230016c8 <dma_reload+0x17c>
    {
        if (transfer_size % 2)
230015f6:	001c7793          	andi	a5,s8,1
            return -1;
230015fa:	557d                	li	a0,-1
        if (transfer_size % 2)
230015fc:	efb5                	bnez	a5,23001678 <dma_reload+0x12c>

        actual_transfer_offset = (4095 * 2);
230015fe:	6b09                	lui	s6,0x2
        actual_transfer_len = transfer_size/2;
23001600:	001c5c13          	srli	s8,s8,0x1
        actual_transfer_offset = (4095 * 2);
23001604:	1b79                	addi	s6,s6,-2

        actual_transfer_offset = (4095 * 4);
        actual_transfer_len = transfer_size/4;
    }

    malloc_count = actual_transfer_len / 4095;
23001606:	6a05                	lui	s4,0x1
23001608:	1a7d                	addi	s4,s4,-1
2300160a:	034c5bb3          	divu	s7,s8,s4
    remain_len = actual_transfer_len % 4095;
2300160e:	034c7a33          	remu	s4,s8,s4

    if (remain_len)
23001612:	000a0363          	beqz	s4,23001618 <dma_reload+0xcc>
    {
        malloc_count++;
23001616:	0b85                	addi	s7,s7,1
    }

    if(dma_device->lli_cfg)
23001618:	044aa503          	lw	a0,68(s5)
2300161c:	004b9c13          	slli	s8,s7,0x4
23001620:	c119                	beqz	a0,23001626 <dma_reload+0xda>
    {
        mmheap_free(dma_device->lli_cfg);
23001622:	028040ef          	jal	ra,2300564a <mmheap_free>
        dma_device->lli_cfg = (dma_lli_ctrl_t *)mmheap_alloc(sizeof(dma_lli_ctrl_t) * malloc_count);
    }
    else
    {
         dma_device->lli_cfg = (dma_lli_ctrl_t *)mmheap_alloc(sizeof(dma_lli_ctrl_t) * malloc_count);
23001626:	8562                	mv	a0,s8
23001628:	7db030ef          	jal	ra,23005602 <mmheap_alloc>
2300162c:	04aaa223          	sw	a0,68(s5)
    }

    if (dma_device->lli_cfg)
23001630:	044aa783          	lw	a5,68(s5)
        }
        DMA_LLI_Update(dma_device->ch, (uint32_t)dma_device->lli_cfg);
    }
    else
    {
        return -2;
23001634:	5579                	li	a0,-2
    if (dma_device->lli_cfg)
23001636:	c3a9                	beqz	a5,23001678 <dma_reload+0x12c>
        if ((!remain_len) && (malloc_count == 1))
23001638:	1a0a1563          	bnez	s4,230017e2 <dma_reload+0x296>
2300163c:	4705                	li	a4,1
2300163e:	0aeb9763          	bne	s7,a4,230016ec <dma_reload+0x1a0>
            dma_ctrl_cfg.bits.TransferSize = remain_len;
23001642:	4014                	lw	a3,0(s0)
23001644:	7ffff737          	lui	a4,0x7ffff
            dma_device->lli_cfg[0].src_addr = src_addr;
23001648:	c384                	sw	s1,0(a5)
            dma_ctrl_cfg.bits.TransferSize = remain_len;
2300164a:	8f75                	and	a4,a4,a3
2300164c:	800006b7          	lui	a3,0x80000
23001650:	8f55                	or	a4,a4,a3
            dma_device->lli_cfg[0].dst_addr = dst_addr;
23001652:	0127a223          	sw	s2,4(a5) # fff40004 <__HeapLimit+0xbdf14004>
            dma_device->lli_cfg[0].nextlli = 0;
23001656:	0007a423          	sw	zero,8(a5)
            memcpy(&dma_device->lli_cfg[0].cfg, &dma_ctrl_cfg, sizeof(dma_control_data_t));
2300165a:	4611                	li	a2,4
2300165c:	44098593          	addi	a1,s3,1088
23001660:	00c78513          	addi	a0,a5,12
            dma_ctrl_cfg.bits.TransferSize = remain_len;
23001664:	c018                	sw	a4,0(s0)
            memcpy(&dma_device->lli_cfg[0].cfg, &dma_ctrl_cfg, sizeof(dma_control_data_t));
23001666:	59a030ef          	jal	ra,23004c00 <memcpy>
        DMA_LLI_Update(dma_device->ch, (uint32_t)dma_device->lli_cfg);
2300166a:	035ac503          	lbu	a0,53(s5)
2300166e:	044aa583          	lw	a1,68(s5)
23001672:	6ca010ef          	jal	ra,23002d3c <DMA_LLI_Update>
    }

    return 0;
23001676:	4501                	li	a0,0
}
23001678:	40b6                	lw	ra,76(sp)
2300167a:	4426                	lw	s0,72(sp)
2300167c:	4496                	lw	s1,68(sp)
2300167e:	4906                	lw	s2,64(sp)
23001680:	59f2                	lw	s3,60(sp)
23001682:	5a62                	lw	s4,56(sp)
23001684:	5ad2                	lw	s5,52(sp)
23001686:	5b42                	lw	s6,48(sp)
23001688:	5bb2                	lw	s7,44(sp)
2300168a:	5c22                	lw	s8,40(sp)
2300168c:	5c92                	lw	s9,36(sp)
2300168e:	5d02                	lw	s10,32(sp)
23001690:	4df2                	lw	s11,28(sp)
23001692:	6161                	addi	sp,sp,80
23001694:	8082                	ret
    else if (dma_device->direction == DMA_MEMORY_TO_PERIPH)
23001696:	4705                	li	a4,1
23001698:	00e79863          	bne	a5,a4,230016a8 <dma_reload+0x15c>
        dma_ctrl_cfg.bits.SI = 1;
2300169c:	00344783          	lbu	a5,3(s0)
230016a0:	9bcd                	andi	a5,a5,-13
230016a2:	0047e793          	ori	a5,a5,4
230016a6:	b5f5                	j	23001592 <dma_reload+0x46>
    else if (dma_device->direction == DMA_PERIPH_TO_MEMORY)
230016a8:	4709                	li	a4,2
230016aa:	00e79863          	bne	a5,a4,230016ba <dma_reload+0x16e>
        dma_ctrl_cfg.bits.SI = 0;
230016ae:	00344783          	lbu	a5,3(s0)
230016b2:	9bcd                	andi	a5,a5,-13
230016b4:	0087e793          	ori	a5,a5,8
230016b8:	bde9                	j	23001592 <dma_reload+0x46>
    else if (dma_device->direction == DMA_PERIPH_TO_PERIPH)
230016ba:	470d                	li	a4,3
230016bc:	ece79de3          	bne	a5,a4,23001596 <dma_reload+0x4a>
        dma_ctrl_cfg.bits.SI = 0;
230016c0:	00344783          	lbu	a5,3(s0)
230016c4:	9bcd                	andi	a5,a5,-13
230016c6:	b5f1                	j	23001592 <dma_reload+0x46>
    else if (dma_device->src_width == DMA_TRANSFER_WIDTH_32BIT)
230016c8:	4789                	li	a5,2
230016ca:	00f69e63          	bne	a3,a5,230016e6 <dma_reload+0x19a>
        if (transfer_size % 4)
230016ce:	003c7793          	andi	a5,s8,3
            return -1;
230016d2:	557d                	li	a0,-1
        if (transfer_size % 4)
230016d4:	f3d5                	bnez	a5,23001678 <dma_reload+0x12c>
        actual_transfer_offset = (4095 * 4);
230016d6:	6b11                	lui	s6,0x4
        actual_transfer_len = transfer_size/4;
230016d8:	002c5c13          	srli	s8,s8,0x2
        actual_transfer_offset = (4095 * 4);
230016dc:	1b71                	addi	s6,s6,-4
230016de:	b725                	j	23001606 <dma_reload+0xba>
        actual_transfer_offset = 4095;
230016e0:	6b05                	lui	s6,0x1
230016e2:	1b7d                	addi	s6,s6,-1
230016e4:	b70d                	j	23001606 <dma_reload+0xba>
    uint32_t actual_transfer_offset = 0;
230016e6:	4b01                	li	s6,0
    uint32_t actual_transfer_len = 0;
230016e8:	4c01                	li	s8,0
230016ea:	bf31                	j	23001606 <dma_reload+0xba>
        else if ((!remain_len) && (malloc_count > 1))
230016ec:	0f777b63          	bgeu	a4,s7,230017e2 <dma_reload+0x296>
                dma_ctrl_cfg.bits.TransferSize = 4095;
230016f0:	6c05                	lui	s8,0x1
230016f2:	7ffffcb7          	lui	s9,0x7ffff
230016f6:	1c7d                	addi	s8,s8,-1
                if (i == malloc_count - 1)
230016f8:	fffb8d13          	addi	s10,s7,-1
                    dma_ctrl_cfg.bits.I = 1;
230016fc:	80000db7          	lui	s11,0x80000
                    if (dma_device->transfer_mode == DMA_LLI_CYCLE_MODE)
23001700:	4685                	li	a3,1
                dma_device->lli_cfg[i].src_addr = src_addr;
23001702:	044aa703          	lw	a4,68(s5)
                dma_ctrl_cfg.bits.TransferSize = 4095;
23001706:	401c                	lw	a5,0(s0)
23001708:	004a1513          	slli	a0,s4,0x4
                dma_device->lli_cfg[i].src_addr = src_addr;
2300170c:	953a                	add	a0,a0,a4
2300170e:	c104                	sw	s1,0(a0)
                dma_ctrl_cfg.bits.TransferSize = 4095;
23001710:	00fcf7b3          	and	a5,s9,a5
23001714:	0187e7b3          	or	a5,a5,s8
                dma_device->lli_cfg[i].dst_addr = dst_addr;
23001718:	01252223          	sw	s2,4(a0)
                dma_device->lli_cfg[i].nextlli = 0;
2300171c:	00052423          	sw	zero,8(a0)
                dma_ctrl_cfg.bits.TransferSize = 4095;
23001720:	c01c                	sw	a5,0(s0)
                if (dma_ctrl_cfg.bits.SI)
23001722:	00579613          	slli	a2,a5,0x5
23001726:	00065363          	bgez	a2,2300172c <dma_reload+0x1e0>
                    src_addr += actual_transfer_offset;
2300172a:	94da                	add	s1,s1,s6
                if (dma_ctrl_cfg.bits.DI)
2300172c:	00479613          	slli	a2,a5,0x4
23001730:	00065363          	bgez	a2,23001736 <dma_reload+0x1ea>
                    dst_addr += actual_transfer_offset;
23001734:	995a                	add	s2,s2,s6
                if (i == malloc_count - 1)
23001736:	014d1e63          	bne	s10,s4,23001752 <dma_reload+0x206>
                    dma_ctrl_cfg.bits.I = 1;
2300173a:	401c                	lw	a5,0(s0)
2300173c:	01b7e7b3          	or	a5,a5,s11
23001740:	c01c                	sw	a5,0(s0)
                    if (dma_device->transfer_mode == DMA_LLI_CYCLE_MODE)
23001742:	037ac783          	lbu	a5,55(s5)
23001746:	00d79363          	bne	a5,a3,2300174c <dma_reload+0x200>
                        dma_device->lli_cfg[i].nextlli = (uint32_t)&dma_device->lli_cfg[0];
2300174a:	c518                	sw	a4,8(a0)
                    dma_device->lli_cfg[i - 1].nextlli = (uint32_t)&dma_device->lli_cfg[i];
2300174c:	fea52c23          	sw	a0,-8(a0)
23001750:	a019                	j	23001756 <dma_reload+0x20a>
                if (i)
23001752:	fe0a1de3          	bnez	s4,2300174c <dma_reload+0x200>
                memcpy(&dma_device->lli_cfg[i].cfg, &dma_ctrl_cfg, sizeof(dma_control_data_t));
23001756:	4611                	li	a2,4
23001758:	44098593          	addi	a1,s3,1088
2300175c:	0531                	addi	a0,a0,12
2300175e:	4a2030ef          	jal	ra,23004c00 <memcpy>
            for (uint32_t i = 0; i < malloc_count; i++)
23001762:	0a05                	addi	s4,s4,1
23001764:	4685                	li	a3,1
23001766:	f94b9ee3          	bne	s7,s4,23001702 <dma_reload+0x1b6>
2300176a:	b701                	j	2300166a <dma_reload+0x11e>
                dma_ctrl_cfg.bits.TransferSize = 4095;
2300176c:	401c                	lw	a5,0(s0)
2300176e:	004c1513          	slli	a0,s8,0x4
                dma_device->lli_cfg[i].src_addr = src_addr;
23001772:	953a                	add	a0,a0,a4
23001774:	c104                	sw	s1,0(a0)
                dma_ctrl_cfg.bits.TransferSize = 4095;
23001776:	00fdf7b3          	and	a5,s11,a5
2300177a:	0197e7b3          	or	a5,a5,s9
                dma_device->lli_cfg[i].dst_addr = dst_addr;
2300177e:	01252223          	sw	s2,4(a0)
                dma_device->lli_cfg[i].nextlli = 0;
23001782:	00052423          	sw	zero,8(a0)
                dma_ctrl_cfg.bits.TransferSize = 4095;
23001786:	c01c                	sw	a5,0(s0)
                if (dma_ctrl_cfg.bits.SI)
23001788:	00579613          	slli	a2,a5,0x5
2300178c:	00065363          	bgez	a2,23001792 <dma_reload+0x246>
                    src_addr += actual_transfer_offset;
23001790:	94da                	add	s1,s1,s6
                if (dma_ctrl_cfg.bits.DI)
23001792:	00479613          	slli	a2,a5,0x4
23001796:	00065363          	bgez	a2,2300179c <dma_reload+0x250>
                    dst_addr += actual_transfer_offset;
2300179a:	995a                	add	s2,s2,s6
                if (i == malloc_count - 1)
2300179c:	03869163          	bne	a3,s8,230017be <dma_reload+0x272>
                    dma_ctrl_cfg.bits.TransferSize = remain_len;
230017a0:	401c                	lw	a5,0(s0)
                    dma_ctrl_cfg.bits.I = 1;
230017a2:	80000637          	lui	a2,0x80000
                    dma_ctrl_cfg.bits.TransferSize = remain_len;
230017a6:	01a7f7b3          	and	a5,a5,s10
230017aa:	0147e7b3          	or	a5,a5,s4
                    dma_ctrl_cfg.bits.I = 1;
230017ae:	8fd1                	or	a5,a5,a2
230017b0:	c01c                	sw	a5,0(s0)
                    if (dma_device->transfer_mode == DMA_LLI_CYCLE_MODE)
230017b2:	037ac603          	lbu	a2,55(s5)
230017b6:	4785                	li	a5,1
230017b8:	00f61363          	bne	a2,a5,230017be <dma_reload+0x272>
                        dma_device->lli_cfg[i].nextlli = (uint32_t)&dma_device->lli_cfg[0];
230017bc:	c518                	sw	a4,8(a0)
                if (i)
230017be:	000c0463          	beqz	s8,230017c6 <dma_reload+0x27a>
                    dma_device->lli_cfg[i - 1].nextlli = (uint32_t)&dma_device->lli_cfg[i];
230017c2:	fea52c23          	sw	a0,-8(a0)
                memcpy(&dma_device->lli_cfg[i].cfg, &dma_ctrl_cfg, sizeof(dma_control_data_t));
230017c6:	4611                	li	a2,4
230017c8:	44098593          	addi	a1,s3,1088
230017cc:	0531                	addi	a0,a0,12
230017ce:	c636                	sw	a3,12(sp)
230017d0:	430030ef          	jal	ra,23004c00 <memcpy>
            for (uint32_t i = 0; i < malloc_count; i++)
230017d4:	0c05                	addi	s8,s8,1
230017d6:	46b2                	lw	a3,12(sp)
230017d8:	044aa703          	lw	a4,68(s5)
230017dc:	f98b98e3          	bne	s7,s8,2300176c <dma_reload+0x220>
230017e0:	b569                	j	2300166a <dma_reload+0x11e>
                dma_ctrl_cfg.bits.TransferSize = 4095;
230017e2:	6c85                	lui	s9,0x1
230017e4:	1cfd                	addi	s9,s9,-1
230017e6:	4c01                	li	s8,0
230017e8:	7ffffdb7          	lui	s11,0x7ffff
                if (i == malloc_count - 1)
230017ec:	fffb8693          	addi	a3,s7,-1
                    dma_ctrl_cfg.bits.TransferSize = remain_len;
230017f0:	019a7a33          	and	s4,s4,s9
230017f4:	7d7d                	lui	s10,0xfffff
230017f6:	b7cd                	j	230017d8 <dma_reload+0x28c>

230017f8 <dma_isr>:
{
    uint32_t tmpVal;
    uint32_t intClr;

    /* Get DMA register */
    if (handle->id == 0)
230017f8:	03454783          	lbu	a5,52(a0)
230017fc:	e3d5                	bnez	a5,230018a0 <dma_isr+0xa8>
{
230017fe:	1101                	addi	sp,sp,-32
23001800:	cc22                	sw	s0,24(sp)
23001802:	ca26                	sw	s1,20(sp)
23001804:	c84a                	sw	s2,16(sp)
23001806:	c64e                	sw	s3,12(sp)
23001808:	c452                	sw	s4,8(sp)
2300180a:	ce06                	sw	ra,28(sp)
2300180c:	842a                	mv	s0,a0
2300180e:	0d850993          	addi	s3,a0,216
    if (handle->id == 0)
23001812:	84aa                	mv	s1,a0
    {
        uint32_t DMAChs = DMA_BASE;
        for (uint8_t i = 0; i < DMA_MAX_INDEX; i++)
        {
            tmpVal = BL_RD_REG(DMAChs, DMA_INTTCSTATUS);
23001814:	4000c937          	lui	s2,0x4000c
            if ((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCSTATUS) & (1 << handle[i].ch)) != 0)
23001818:	4a05                	li	s4,1
2300181a:	0354c783          	lbu	a5,53(s1)
            tmpVal = BL_RD_REG(DMAChs, DMA_INTTCSTATUS);
2300181e:	00492703          	lw	a4,4(s2) # 4000c004 <__ram_load_addr+0x1cfff0e0>
            if ((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCSTATUS) & (1 << handle[i].ch)) != 0)
23001822:	00fa17b3          	sll	a5,s4,a5
23001826:	8f7d                	and	a4,a4,a5
23001828:	0ff77713          	andi	a4,a4,255
2300182c:	cf09                	beqz	a4,23001846 <dma_isr+0x4e>
            {
                /* Clear interrupt */
                tmpVal = BL_RD_REG(DMAChs, DMA_INTTCCLEAR);
2300182e:	00892703          	lw	a4,8(s2)
                intClr = BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCCLEAR);
                intClr |= (1 << handle[i].ch);
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_INTTCCLEAR, intClr);
23001832:	8fd9                	or	a5,a5,a4
                BL_WR_REG(DMAChs, DMA_INTTCCLEAR, tmpVal);
23001834:	00f92423          	sw	a5,8(s2)

                if (handle[i].parent.callback)
23001838:	54dc                	lw	a5,44(s1)
2300183a:	c791                	beqz	a5,23001846 <dma_isr+0x4e>
                    handle[i].parent.callback(&handle[i].parent, NULL, 0, DMA_INT_TCOMPLETED);
2300183c:	4681                	li	a3,0
2300183e:	4601                	li	a2,0
23001840:	4581                	li	a1,0
23001842:	8526                	mv	a0,s1
23001844:	9782                	jalr	a5
        for (uint8_t i = 0; i < DMA_MAX_INDEX; i++)
23001846:	04848493          	addi	s1,s1,72
2300184a:	fc9998e3          	bne	s3,s1,2300181a <dma_isr+0x22>
2300184e:	02c40493          	addi	s1,s0,44
23001852:	10440993          	addi	s3,s0,260
            }
        }

        for (uint8_t i = 0; i < DMA_MAX_INDEX; i++)
        {
            tmpVal = BL_RD_REG(DMAChs, DMA_INTERRORSTATUS);
23001856:	4000c937          	lui	s2,0x4000c
            if ((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRORSTATUS) & (1 << handle[i].ch)) != 0)
2300185a:	4a05                	li	s4,1
2300185c:	0094c783          	lbu	a5,9(s1)
            tmpVal = BL_RD_REG(DMAChs, DMA_INTERRORSTATUS);
23001860:	00c92703          	lw	a4,12(s2) # 4000c00c <__ram_load_addr+0x1cfff0e8>
            if ((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRORSTATUS) & (1 << handle[i].ch)) != 0)
23001864:	00fa17b3          	sll	a5,s4,a5
23001868:	8f7d                	and	a4,a4,a5
2300186a:	0ff77713          	andi	a4,a4,255
2300186e:	cf09                	beqz	a4,23001888 <dma_isr+0x90>
            {
                /*Clear interrupt */
                tmpVal = BL_RD_REG(DMAChs, DMA_INTERRCLR);
23001870:	01092703          	lw	a4,16(s2)
                intClr = BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRCLR);
                intClr |= (1 << handle[i].ch);
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_INTERRCLR, intClr);
23001874:	8fd9                	or	a5,a5,a4
                BL_WR_REG(DMAChs, DMA_INTERRCLR, tmpVal);
23001876:	00f92823          	sw	a5,16(s2)

                if (handle[i].parent.callback)
2300187a:	409c                	lw	a5,0(s1)
2300187c:	c791                	beqz	a5,23001888 <dma_isr+0x90>
                    handle[i].parent.callback(&handle->parent, NULL, 0, DMA_INT_ERR);
2300187e:	4685                	li	a3,1
23001880:	4601                	li	a2,0
23001882:	4581                	li	a1,0
23001884:	8522                	mv	a0,s0
23001886:	9782                	jalr	a5
        for (uint8_t i = 0; i < DMA_MAX_INDEX; i++)
23001888:	04848493          	addi	s1,s1,72
2300188c:	fc9998e3          	bne	s3,s1,2300185c <dma_isr+0x64>
        }
    }
    else
    {
    }
}
23001890:	40f2                	lw	ra,28(sp)
23001892:	4462                	lw	s0,24(sp)
23001894:	44d2                	lw	s1,20(sp)
23001896:	4942                	lw	s2,16(sp)
23001898:	49b2                	lw	s3,12(sp)
2300189a:	4a22                	lw	s4,8(sp)
2300189c:	6105                	addi	sp,sp,32
2300189e:	8082                	ret
230018a0:	8082                	ret

230018a2 <DMA0_IRQ>:
 * @brief 
 * 
 */
void DMA0_IRQ(void)
{
    dma_isr(&dmax_device[0]);
230018a2:	42024537          	lui	a0,0x42024
230018a6:	0f450513          	addi	a0,a0,244 # 420240f4 <dmax_device>
230018aa:	b7b9                	j	230017f8 <dma_isr>

230018ac <GPIO_IRQ>:

    device_register(dev, name, flag);
}

static void GPIO_IRQ(void)
{
230018ac:	1101                	addi	sp,sp,-32
	slist_t *i;
    uint32_t timeOut=0;
#define GLB_GPIO_INT0_CLEAR_TIMEOUT     (32)
	slist_for_each(i,&gpio_int_head)
230018ae:	420257b7          	lui	a5,0x42025
{
230018b2:	cc22                	sw	s0,24(sp)
	slist_for_each(i,&gpio_int_head)
230018b4:	4447a403          	lw	s0,1092(a5) # 42025444 <gpio_int_head>
{
230018b8:	c84a                	sw	s2,16(sp)
230018ba:	c64e                	sw	s3,12(sp)
230018bc:	ce06                	sw	ra,28(sp)
230018be:	ca26                	sw	s1,20(sp)
    {
        struct gpio_int_cfg_private* int_cfg = slist_entry(i,struct gpio_int_cfg_private,list);
        if(SET==GLB_Get_GPIO_IntStatus(int_cfg->pin))
230018c0:	4905                	li	s2,1
            timeOut=GLB_GPIO_INT0_CLEAR_TIMEOUT;
            do{
                timeOut--;
            }while((SET==GLB_Get_GPIO_IntStatus(int_cfg->pin))&&timeOut);
            if(!timeOut){
                MSG("WARNING: Clear GPIO interrupt status fail.\r\n");
230018c2:	230069b7          	lui	s3,0x23006
	slist_for_each(i,&gpio_int_head)
230018c6:	e801                	bnez	s0,230018d6 <GPIO_IRQ+0x2a>
            }
            GLB_GPIO_IntClear(int_cfg->pin,RESET);
        }
    }
    
230018c8:	40f2                	lw	ra,28(sp)
230018ca:	4462                	lw	s0,24(sp)
230018cc:	44d2                	lw	s1,20(sp)
230018ce:	4942                	lw	s2,16(sp)
230018d0:	49b2                	lw	s3,12(sp)
230018d2:	6105                	addi	sp,sp,32
230018d4:	8082                	ret
        if(SET==GLB_Get_GPIO_IntStatus(int_cfg->pin))
230018d6:	00444503          	lbu	a0,4(s0)
230018da:	7b0010ef          	jal	ra,2300308a <GLB_Get_GPIO_IntStatus>
230018de:	03251f63          	bne	a0,s2,2300191c <GPIO_IRQ+0x70>
            int_cfg->cbfun(int_cfg->pin);
230018e2:	441c                	lw	a5,8(s0)
230018e4:	4048                	lw	a0,4(s0)
            timeOut=GLB_GPIO_INT0_CLEAR_TIMEOUT;
230018e6:	02000493          	li	s1,32
            int_cfg->cbfun(int_cfg->pin);
230018ea:	9782                	jalr	a5
            GLB_GPIO_IntClear(int_cfg->pin,SET);
230018ec:	00444503          	lbu	a0,4(s0)
230018f0:	4585                	li	a1,1
230018f2:	76a010ef          	jal	ra,2300305c <GLB_GPIO_IntClear>
            }while((SET==GLB_Get_GPIO_IntStatus(int_cfg->pin))&&timeOut);
230018f6:	00444503          	lbu	a0,4(s0)
                timeOut--;
230018fa:	14fd                	addi	s1,s1,-1
            }while((SET==GLB_Get_GPIO_IntStatus(int_cfg->pin))&&timeOut);
230018fc:	78e010ef          	jal	ra,2300308a <GLB_Get_GPIO_IntStatus>
23001900:	01251863          	bne	a0,s2,23001910 <GPIO_IRQ+0x64>
23001904:	f8ed                	bnez	s1,230018f6 <GPIO_IRQ+0x4a>
                MSG("WARNING: Clear GPIO interrupt status fail.\r\n");
23001906:	de898513          	addi	a0,s3,-536 # 23005de8 <af_pin_table+0x23c>
2300190a:	fe8ff0ef          	jal	ra,230010f2 <bflb_platform_printf>
2300190e:	a011                	j	23001912 <GPIO_IRQ+0x66>
            if(!timeOut){
23001910:	d8fd                	beqz	s1,23001906 <GPIO_IRQ+0x5a>
            GLB_GPIO_IntClear(int_cfg->pin,RESET);
23001912:	00444503          	lbu	a0,4(s0)
23001916:	4581                	li	a1,0
23001918:	744010ef          	jal	ra,2300305c <GLB_GPIO_IntClear>
	slist_for_each(i,&gpio_int_head)
2300191c:	4000                	lw	s0,0(s0)
2300191e:	b765                	j	230018c6 <GPIO_IRQ+0x1a>

23001920 <gpio_set_mode>:
    gpio_cfg.gpioFun = GPIO_FUN_GPIO;
23001920:	47ad                	li	a5,11
{
23001922:	1101                	addi	sp,sp,-32
23001924:	ca26                	sw	s1,20(sp)
    gpio_cfg.gpioFun = GPIO_FUN_GPIO;
23001926:	00f104a3          	sb	a5,9(sp)
    gpio_cfg.gpioPin = pin;
2300192a:	0ff57493          	andi	s1,a0,255
    gpio_cfg.drive = 0;
2300192e:	10000793          	li	a5,256
{
23001932:	cc22                	sw	s0,24(sp)
    gpio_cfg.drive = 0;
23001934:	00f11623          	sh	a5,12(sp)
{
23001938:	ce06                	sw	ra,28(sp)
    gpio_cfg.gpioPin = pin;
2300193a:	00910423          	sb	s1,8(sp)
    switch (mode)
2300193e:	4795                	li	a5,5
{
23001940:	842e                	mv	s0,a1
    switch (mode)
23001942:	04b7e763          	bltu	a5,a1,23001990 <gpio_set_mode+0x70>
23001946:	230067b7          	lui	a5,0x23006
2300194a:	dd078793          	addi	a5,a5,-560 # 23005dd0 <af_pin_table+0x224>
2300194e:	00259413          	slli	s0,a1,0x2
23001952:	943e                	add	s0,s0,a5
23001954:	401c                	lw	a5,0(s0)
23001956:	8782                	jr	a5
            gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
23001958:	20100793          	li	a5,513
            gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
2300195c:	00f11523          	sh	a5,10(sp)
    GLB_GPIO_Init(&gpio_cfg);
23001960:	0028                	addi	a0,sp,8
23001962:	ff014097          	auipc	ra,0xff014
23001966:	a2e080e7          	jalr	-1490(ra) # 22015390 <GLB_GPIO_Init>
}
2300196a:	40f2                	lw	ra,28(sp)
2300196c:	4462                	lw	s0,24(sp)
2300196e:	44d2                	lw	s1,20(sp)
23001970:	6105                	addi	sp,sp,32
23001972:	8082                	ret
            gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
23001974:	4785                	li	a5,1
23001976:	b7dd                	j	2300195c <gpio_set_mode+0x3c>
            gpio_cfg.gpioMode = GPIO_MODE_OUTPUT;
23001978:	10100793          	li	a5,257
2300197c:	b7c5                	j	2300195c <gpio_set_mode+0x3c>
            gpio_cfg.gpioMode = GPIO_MODE_INPUT;
2300197e:	20000793          	li	a5,512
23001982:	bfe9                	j	2300195c <gpio_set_mode+0x3c>
            gpio_cfg.gpioMode = GPIO_MODE_INPUT;
23001984:	00011523          	sh	zero,10(sp)
            break;
23001988:	bfe1                	j	23001960 <gpio_set_mode+0x40>
            gpio_cfg.gpioMode = GPIO_MODE_INPUT;
2300198a:	10000793          	li	a5,256
2300198e:	b7f9                	j	2300195c <gpio_set_mode+0x3c>
            NVIC_DisableIRQ(GPIO_INT0_IRQn);
23001990:	03c00513          	li	a0,60
23001994:	7fb000ef          	jal	ra,2300298e <clic_disable_interrupt>
            GLB_GPIO_IntMask(pin, MASK);
23001998:	4585                	li	a1,1
2300199a:	8526                	mv	a0,s1
2300199c:	692010ef          	jal	ra,2300302e <GLB_GPIO_IntMask>
            gpio_cfg.gpioMode = GPIO_MODE_INPUT;
230019a0:	00010523          	sb	zero,10(sp)
            Interrupt_Handler_Register(GPIO_INT0_IRQn,GPIO_IRQ);
230019a4:	230025b7          	lui	a1,0x23002
230019a8:	8ac58593          	addi	a1,a1,-1876 # 230018ac <GPIO_IRQ>
230019ac:	03c00513          	li	a0,60
230019b0:	19e010ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
            if (mode == GPIO_ASYNC_RISING_TRIGER_INT_MODE)
230019b4:	4799                	li	a5,6
230019b6:	00f41f63          	bne	s0,a5,230019d4 <gpio_set_mode+0xb4>
                gpio_cfg.pullType = GPIO_PULL_DOWN;
230019ba:	4785                	li	a5,1
230019bc:	00f105a3          	sb	a5,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_ASYNC, GLB_GPIO_INT_TRIG_POS_PULSE);
230019c0:	4605                	li	a2,1
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_ASYNC, GLB_GPIO_INT_TRIG_NEG_LEVEL);
230019c2:	4585                	li	a1,1
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_NEG_LEVEL);
230019c4:	8526                	mv	a0,s1
230019c6:	6e2010ef          	jal	ra,230030a8 <GLB_Set_GPIO_IntMod>
            NVIC_EnableIRQ(GPIO_INT0_IRQn);
230019ca:	03c00513          	li	a0,60
230019ce:	7af000ef          	jal	ra,2300297c <clic_enable_interrupt>
            break;
230019d2:	b779                	j	23001960 <gpio_set_mode+0x40>
            else if (mode == GPIO_ASYNC_FALLING_TRIGER_INT_MODE)
230019d4:	479d                	li	a5,7
230019d6:	00f41663          	bne	s0,a5,230019e2 <gpio_set_mode+0xc2>
                gpio_cfg.pullType = GPIO_PULL_UP;
230019da:	000105a3          	sb	zero,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_ASYNC, GLB_GPIO_INT_TRIG_NEG_PULSE);
230019de:	4601                	li	a2,0
230019e0:	b7cd                	j	230019c2 <gpio_set_mode+0xa2>
            else if (mode == GPIO_ASYNC_HIGH_LEVEL_INT_MODE)
230019e2:	47a1                	li	a5,8
230019e4:	00f41763          	bne	s0,a5,230019f2 <gpio_set_mode+0xd2>
                gpio_cfg.pullType = GPIO_PULL_DOWN;
230019e8:	4785                	li	a5,1
230019ea:	00f105a3          	sb	a5,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_ASYNC, GLB_GPIO_INT_TRIG_POS_LEVEL);
230019ee:	460d                	li	a2,3
230019f0:	bfc9                	j	230019c2 <gpio_set_mode+0xa2>
            else if (mode == GPIO_ASYNC_LOW_LEVEL_INT_MODE)
230019f2:	47a5                	li	a5,9
230019f4:	00f41663          	bne	s0,a5,23001a00 <gpio_set_mode+0xe0>
                gpio_cfg.pullType = GPIO_PULL_UP;
230019f8:	000105a3          	sb	zero,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_ASYNC, GLB_GPIO_INT_TRIG_NEG_LEVEL);
230019fc:	4609                	li	a2,2
230019fe:	b7d1                	j	230019c2 <gpio_set_mode+0xa2>
            else if (mode == GPIO_SYNC_RISING_TRIGER_INT_MODE)
23001a00:	47a9                	li	a5,10
23001a02:	00f41863          	bne	s0,a5,23001a12 <gpio_set_mode+0xf2>
                gpio_cfg.pullType = GPIO_PULL_DOWN;
23001a06:	4785                	li	a5,1
23001a08:	00f105a3          	sb	a5,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_POS_PULSE);
23001a0c:	4605                	li	a2,1
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_NEG_LEVEL);
23001a0e:	4581                	li	a1,0
23001a10:	bf55                	j	230019c4 <gpio_set_mode+0xa4>
            else if (mode == GPIO_SYNC_FALLING_TRIGER_INT_MODE)
23001a12:	47ad                	li	a5,11
23001a14:	00f41663          	bne	s0,a5,23001a20 <gpio_set_mode+0x100>
                gpio_cfg.pullType = GPIO_PULL_UP;
23001a18:	000105a3          	sb	zero,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_NEG_PULSE);
23001a1c:	4601                	li	a2,0
23001a1e:	bfc5                	j	23001a0e <gpio_set_mode+0xee>
            else if (mode == GPIO_SYNC_HIGH_LEVEL_INT_MODE)
23001a20:	47b1                	li	a5,12
23001a22:	00f41763          	bne	s0,a5,23001a30 <gpio_set_mode+0x110>
                gpio_cfg.pullType = GPIO_PULL_DOWN;
23001a26:	4785                	li	a5,1
23001a28:	00f105a3          	sb	a5,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_POS_LEVEL);
23001a2c:	460d                	li	a2,3
23001a2e:	b7c5                	j	23001a0e <gpio_set_mode+0xee>
            else if (mode == GPIO_SYNC_LOW_LEVEL_INT_MODE)
23001a30:	47b5                	li	a5,13
23001a32:	f2f41ce3          	bne	s0,a5,2300196a <gpio_set_mode+0x4a>
                gpio_cfg.pullType = GPIO_PULL_UP;
23001a36:	000105a3          	sb	zero,11(sp)
                GLB_Set_GPIO_IntMod(pin, GLB_GPIO_INT_CONTROL_SYNC, GLB_GPIO_INT_TRIG_NEG_LEVEL);
23001a3a:	4609                	li	a2,2
23001a3c:	bfc9                	j	23001a0e <gpio_set_mode+0xee>

23001a3e <gpio_write>:
    GLB_GPIO_Write(pin, value);
23001a3e:	0ff57513          	andi	a0,a0,255
23001a42:	59c0106f          	j	23002fde <GLB_GPIO_Write>

23001a46 <mtimer_get_time_us>:

    uint32_t tmpValLow, tmpValHigh, tmpValHigh1;

    do
    {
        tmpValLow = *(volatile uint32_t *)(CLIC_CTRL_ADDR + CLIC_MTIME);
23001a46:	0200c7b7          	lui	a5,0x200c
23001a4a:	ff87a503          	lw	a0,-8(a5) # 200bff8 <HeapSize+0x200aff8>
        tmpValHigh = *(volatile uint32_t *)(CLIC_CTRL_ADDR + CLIC_MTIME + 4);
23001a4e:	ffc7a583          	lw	a1,-4(a5)
        tmpValHigh1 = *(volatile uint32_t *)(CLIC_CTRL_ADDR + CLIC_MTIME + 4);
23001a52:	ffc7a703          	lw	a4,-4(a5)
    } while (tmpValHigh != tmpValHigh1);
23001a56:	fee59ae3          	bne	a1,a4,23001a4a <mtimer_get_time_us+0x4>

    return (((uint64_t)tmpValHigh << 32) + tmpValLow);

}
23001a5a:	8082                	ret

23001a5c <mtimer_get_time_ms>:
{
23001a5c:	1141                	addi	sp,sp,-16
23001a5e:	c606                	sw	ra,12(sp)
    return mtimer_get_time_us()/1000;
23001a60:	37dd                	jal	23001a46 <mtimer_get_time_us>
23001a62:	3e800613          	li	a2,1000
23001a66:	4681                	li	a3,0
23001a68:	f98fe0ef          	jal	ra,23000200 <__udivdi3>
}
23001a6c:	40b2                	lw	ra,12(sp)
23001a6e:	0141                	addi	sp,sp,16
23001a70:	8082                	ret

23001a72 <mtimer_delay_ms>:
 * @brief 
 * 
 * @param time 
 */
void mtimer_delay_ms(uint32_t time)
{
23001a72:	1101                	addi	sp,sp,-32
    uint64_t cnt = 0;
    uint32_t clock = SystemCoreClockGet();
23001a74:	4000f7b7          	lui	a5,0x4000f
{
23001a78:	cc22                	sw	s0,24(sp)
    uint32_t clock = SystemCoreClockGet();
23001a7a:	1087a403          	lw	s0,264(a5) # 4000f108 <__ram_load_addr+0x1d0021e4>
{
23001a7e:	c64e                	sw	s3,12(sp)
23001a80:	89aa                	mv	s3,a0

    while (mtimer_get_time_ms() - startTime < time)
    {
        cnt++;
        /* assume BFLB_BSP_Get_Time_Ms take 32 cycles*/
        if (cnt > (time * (clock >> (10 + 5))) * 2)
23001a82:	803d                	srli	s0,s0,0xf
23001a84:	03340433          	mul	s0,s0,s3
{
23001a88:	ca26                	sw	s1,20(sp)
23001a8a:	c84a                	sw	s2,16(sp)
23001a8c:	c452                	sw	s4,8(sp)
23001a8e:	c256                	sw	s5,4(sp)
23001a90:	ce06                	sw	ra,28(sp)
    uint64_t startTime = mtimer_get_time_ms();
23001a92:	37e9                	jal	23001a5c <mtimer_get_time_ms>
23001a94:	8a2a                	mv	s4,a0
23001a96:	8aae                	mv	s5,a1
    uint64_t cnt = 0;
23001a98:	4481                	li	s1,0
        if (cnt > (time * (clock >> (10 + 5))) * 2)
23001a9a:	0406                	slli	s0,s0,0x1
    uint64_t cnt = 0;
23001a9c:	4901                	li	s2,0
    while (mtimer_get_time_ms() - startTime < time)
23001a9e:	3f7d                	jal	23001a5c <mtimer_get_time_ms>
23001aa0:	414507b3          	sub	a5,a0,s4
23001aa4:	00f53533          	sltu	a0,a0,a5
23001aa8:	415585b3          	sub	a1,a1,s5
23001aac:	00a59e63          	bne	a1,a0,23001ac8 <mtimer_delay_ms+0x56>
23001ab0:	0137fc63          	bgeu	a5,s3,23001ac8 <mtimer_delay_ms+0x56>
        cnt++;
23001ab4:	00148793          	addi	a5,s1,1
23001ab8:	0097b733          	sltu	a4,a5,s1
23001abc:	993a                	add	s2,s2,a4
23001abe:	84be                	mv	s1,a5
        if (cnt > (time * (clock >> (10 + 5))) * 2)
23001ac0:	00091463          	bnez	s2,23001ac8 <mtimer_delay_ms+0x56>
23001ac4:	fcf47de3          	bgeu	s0,a5,23001a9e <mtimer_delay_ms+0x2c>
        {
            break;
        }
    }
}
23001ac8:	40f2                	lw	ra,28(sp)
23001aca:	4462                	lw	s0,24(sp)
23001acc:	44d2                	lw	s1,20(sp)
23001ace:	4942                	lw	s2,16(sp)
23001ad0:	49b2                	lw	s3,12(sp)
23001ad2:	4a22                	lw	s4,8(sp)
23001ad4:	4a92                	lw	s5,4(sp)
23001ad6:	6105                	addi	sp,sp,32
23001ad8:	8082                	ret

23001ada <uart_close>:
 * 
 * @param dev 
 * @return int 
 */
int uart_close(struct device *dev)
{
23001ada:	1141                	addi	sp,sp,-16
23001adc:	c606                	sw	ra,12(sp)
    uart_device_t *uart_device = (uart_device_t *)dev;

    UART_Disable(uart_device->id, UART_TXRX);
23001ade:	03454503          	lbu	a0,52(a0)
23001ae2:	4589                	li	a1,2
23001ae4:	285010ef          	jal	ra,23003568 <UART_Disable>
    return 0;
}
23001ae8:	40b2                	lw	ra,12(sp)
23001aea:	4501                	li	a0,0
23001aec:	0141                	addi	sp,sp,16
23001aee:	8082                	ret

23001af0 <uart_open>:
{
23001af0:	7179                	addi	sp,sp,-48
23001af2:	d606                	sw	ra,44(sp)
23001af4:	d422                	sw	s0,40(sp)
23001af6:	d226                	sw	s1,36(sp)
23001af8:	842a                	mv	s0,a0
    UART_IntMask(uart_device->id, UART_INT_ALL, MASK);
23001afa:	03454503          	lbu	a0,52(a0)
23001afe:	4605                	li	a2,1
{
23001b00:	84ae                	mv	s1,a1
    UART_IntMask(uart_device->id, UART_INT_ALL, MASK);
23001b02:	45a5                	li	a1,9
    UART_FifoCfg_Type fifoCfg = {0};
23001b04:	c402                	sw	zero,8(sp)
    UART_CFG_Type uart_cfg = {0};
23001b06:	c602                	sw	zero,12(sp)
23001b08:	c802                	sw	zero,16(sp)
23001b0a:	ca02                	sw	zero,20(sp)
23001b0c:	cc02                	sw	zero,24(sp)
23001b0e:	ce02                	sw	zero,28(sp)
    UART_IntMask(uart_device->id, UART_INT_ALL, MASK);
23001b10:	2cb010ef          	jal	ra,230035da <UART_IntMask>
    UART_Disable(uart_device->id, UART_TXRX);
23001b14:	03444503          	lbu	a0,52(s0)
23001b18:	4589                	li	a1,2
23001b1a:	24f010ef          	jal	ra,23003568 <UART_Disable>
    uint32_t uart_clk = peripheral_clock_get(PERIPHERAL_CLOCK_UART);
23001b1e:	4501                	li	a0,0
23001b20:	87dff0ef          	jal	ra,2300139c <peripheral_clock_get>
    uart_cfg.uartClk = uart_clk;
23001b24:	c62a                	sw	a0,12(sp)
    uart_cfg.baudRate = uart_device->baudrate;
23001b26:	5c18                	lw	a4,56(s0)
    uart_cfg.parity = uart_device->parity;
23001b28:	03e44783          	lbu	a5,62(s0)
    UART_Init(uart_device->id, &uart_cfg);
23001b2c:	03444503          	lbu	a0,52(s0)
    uart_cfg.baudRate = uart_device->baudrate;
23001b30:	c83a                	sw	a4,16(sp)
    uart_cfg.dataBits = uart_device->databits;
23001b32:	03c45703          	lhu	a4,60(s0)
    UART_Init(uart_device->id, &uart_cfg);
23001b36:	006c                	addi	a1,sp,12
    uart_cfg.parity = uart_device->parity;
23001b38:	00f10b23          	sb	a5,22(sp)
    uart_cfg.dataBits = uart_device->databits;
23001b3c:	00e11a23          	sh	a4,20(sp)
    uart_cfg.ctsFlowControl = UART_CTS_FLOWCONTROL_ENABLE;
23001b40:	00010ba3          	sb	zero,23(sp)
    uart_cfg.rtsSoftwareControl = UART_RTS_FLOWCONTROL_ENABLE;
23001b44:	00010ca3          	sb	zero,25(sp)
    uart_cfg.txSoftwareControl = UART_TX_SWCONTROL_ENABLE;
23001b48:	00011d23          	sh	zero,26(sp)
    uart_cfg.rxLinMode = UART_RX_LINMODE_ENABLE;
23001b4c:	00011e23          	sh	zero,28(sp)
    uart_cfg.byteBitInverse = UART_MSB_FIRST_ENABLE;
23001b50:	00010f23          	sb	zero,30(sp)
    UART_Init(uart_device->id, &uart_cfg);
23001b54:	047010ef          	jal	ra,2300339a <UART_Init>
    UART_TxFreeRun(uart_device->id, ENABLE);
23001b58:	03444503          	lbu	a0,52(s0)
23001b5c:	4585                	li	a1,1
23001b5e:	259010ef          	jal	ra,230035b6 <UART_TxFreeRun>
    UART_SetRxTimeoutValue(uart_device->id, UART_DEFAULT_RTO_TIMEOUT);
23001b62:	03444503          	lbu	a0,52(s0)
23001b66:	06400593          	li	a1,100
23001b6a:	22f010ef          	jal	ra,23003598 <UART_SetRxTimeoutValue>
    fifoCfg.txFifoDmaEnable = DISABLE;
23001b6e:	00011523          	sh	zero,10(sp)
    fifoCfg.txFifoDmaThreshold = uart_device->fifo_threshold;
23001b72:	03f44783          	lbu	a5,63(s0)
23001b76:	00f10423          	sb	a5,8(sp)
    fifoCfg.rxFifoDmaThreshold = uart_device->fifo_threshold;
23001b7a:	00f104a3          	sb	a5,9(sp)
    if ((oflag & DEVICE_OFLAG_INT_TX) || (oflag & DEVICE_OFLAG_INT_RX))
23001b7e:	00c4f793          	andi	a5,s1,12
23001b82:	cb8d                	beqz	a5,23001bb4 <uart_open+0xc4>
        if (uart_device->id == UART0_ID)
23001b84:	03444783          	lbu	a5,52(s0)
23001b88:	eb89                	bnez	a5,23001b9a <uart_open+0xaa>
            Interrupt_Handler_Register(UART0_IRQn, UART0_IRQ);
23001b8a:	220155b7          	lui	a1,0x22015
23001b8e:	1e458593          	addi	a1,a1,484 # 220151e4 <UART0_IRQ>
23001b92:	02d00513          	li	a0,45
23001b96:	7b9000ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
        if (uart_device->id == UART1_ID)
23001b9a:	03444703          	lbu	a4,52(s0)
23001b9e:	4785                	li	a5,1
23001ba0:	00f71a63          	bne	a4,a5,23001bb4 <uart_open+0xc4>
            Interrupt_Handler_Register(UART1_IRQn, UART1_IRQ);
23001ba4:	230025b7          	lui	a1,0x23002
23001ba8:	e8258593          	addi	a1,a1,-382 # 23001e82 <UART1_IRQ>
23001bac:	02e00513          	li	a0,46
23001bb0:	79f000ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
    if (oflag & DEVICE_OFLAG_DMA_TX)
23001bb4:	0104f793          	andi	a5,s1,16
23001bb8:	c781                	beqz	a5,23001bc0 <uart_open+0xd0>
        fifoCfg.txFifoDmaEnable = ENABLE;
23001bba:	4785                	li	a5,1
23001bbc:	00f10523          	sb	a5,10(sp)
    if (oflag & DEVICE_OFLAG_DMA_RX)
23001bc0:	0204f493          	andi	s1,s1,32
23001bc4:	c481                	beqz	s1,23001bcc <uart_open+0xdc>
        fifoCfg.rxFifoDmaEnable = ENABLE;
23001bc6:	4785                	li	a5,1
23001bc8:	00f105a3          	sb	a5,11(sp)
    UART_FifoConfig(uart_device->id, &fifoCfg);
23001bcc:	03444503          	lbu	a0,52(s0)
23001bd0:	002c                	addi	a1,sp,8
23001bd2:	0f9010ef          	jal	ra,230034ca <UART_FifoConfig>
    UART_Enable(uart_device->id, UART_TXRX);
23001bd6:	03444503          	lbu	a0,52(s0)
23001bda:	4589                	li	a1,2
23001bdc:	159010ef          	jal	ra,23003534 <UART_Enable>
}
23001be0:	5422                	lw	s0,40(sp)
23001be2:	50b2                	lw	ra,44(sp)
23001be4:	5492                	lw	s1,36(sp)
23001be6:	4501                	li	a0,0
23001be8:	6145                	addi	sp,sp,48
23001bea:	8082                	ret

23001bec <uart_control>:
 */
int uart_control(struct device *dev, int cmd, void *args)
{
    uart_device_t *uart_device = (uart_device_t *)dev;

    switch (cmd)
23001bec:	15fd                	addi	a1,a1,-1
23001bee:	47c1                	li	a5,16
23001bf0:	1cb7e363          	bltu	a5,a1,23001db6 <uart_control+0x1ca>
23001bf4:	230067b7          	lui	a5,0x23006
23001bf8:	e1878793          	addi	a5,a5,-488 # 23005e18 <af_pin_table+0x26c>
23001bfc:	058a                	slli	a1,a1,0x2
23001bfe:	95be                	add	a1,a1,a5
23001c00:	419c                	lw	a5,0(a1)
{
23001c02:	7139                	addi	sp,sp,-64
23001c04:	dc22                	sw	s0,56(sp)
23001c06:	da26                	sw	s1,52(sp)
23001c08:	de06                	sw	ra,60(sp)
23001c0a:	d84a                	sw	s2,48(sp)
23001c0c:	d64e                	sw	s3,44(sp)
23001c0e:	d452                	sw	s4,40(sp)
23001c10:	84b2                	mv	s1,a2
23001c12:	842a                	mv	s0,a0
    switch (cmd)
23001c14:	8782                	jr	a5
    {
    case DEVICE_CTRL_SET_INT /* constant-expression */:
    {
        uint32_t offset = __builtin_ctz((uint32_t)args);
23001c16:	8532                	mv	a0,a2
23001c18:	dacfe0ef          	jal	ra,230001c4 <__ctzsi2>
23001c1c:	892a                	mv	s2,a0
        while ((0 <= offset) && (offset < 9))
23001c1e:	49a1                	li	s3,8
        {
            if ((uint32_t)args & (1 << offset))
23001c20:	4a05                	li	s4,1
        while ((0 <= offset) && (offset < 9))
23001c22:	03444503          	lbu	a0,52(s0)
23001c26:	0129f863          	bgeu	s3,s2,23001c36 <uart_control+0x4a>
            {
                UART_IntMask(uart_device->id, offset, UNMASK);
            }
            offset++;
        }
        if (uart_device->id == UART0_ID)
23001c2a:	e10d                	bnez	a0,23001c4c <uart_control+0x60>
            NVIC_EnableIRQ(UART0_IRQn);
23001c2c:	02d00513          	li	a0,45
        else if (uart_device->id == UART1_ID)
            NVIC_EnableIRQ(UART1_IRQn);
23001c30:	54d000ef          	jal	ra,2300297c <clic_enable_interrupt>
23001c34:	a839                	j	23001c52 <uart_control+0x66>
            if ((uint32_t)args & (1 << offset))
23001c36:	012a17b3          	sll	a5,s4,s2
23001c3a:	8fe5                	and	a5,a5,s1
23001c3c:	c791                	beqz	a5,23001c48 <uart_control+0x5c>
                UART_IntMask(uart_device->id, offset, UNMASK);
23001c3e:	4601                	li	a2,0
23001c40:	0ff97593          	andi	a1,s2,255
23001c44:	197010ef          	jal	ra,230035da <UART_IntMask>
            offset++;
23001c48:	0905                	addi	s2,s2,1
23001c4a:	bfe1                	j	23001c22 <uart_control+0x36>
        else if (uart_device->id == UART1_ID)
23001c4c:	4785                	li	a5,1
23001c4e:	00f50463          	beq	a0,a5,23001c56 <uart_control+0x6a>
        return UART_GetRxFifoCount(uart_device->id);
    default:
        break;
    }

    return 0;
23001c52:	4501                	li	a0,0
23001c54:	a291                	j	23001d98 <uart_control+0x1ac>
            NVIC_EnableIRQ(UART1_IRQn);
23001c56:	02e00513          	li	a0,46
23001c5a:	bfd9                	j	23001c30 <uart_control+0x44>
        uint32_t offset = __builtin_ctz((uint32_t)args);
23001c5c:	8532                	mv	a0,a2
23001c5e:	d66fe0ef          	jal	ra,230001c4 <__ctzsi2>
23001c62:	892a                	mv	s2,a0
        while ((0 <= offset) && (offset < 9))
23001c64:	49a1                	li	s3,8
            if ((uint32_t)args & (1 << offset))
23001c66:	4a05                	li	s4,1
        while ((0 <= offset) && (offset < 9))
23001c68:	03444503          	lbu	a0,52(s0)
23001c6c:	0129f863          	bgeu	s3,s2,23001c7c <uart_control+0x90>
        if (uart_device->id == UART0_ID)
23001c70:	e10d                	bnez	a0,23001c92 <uart_control+0xa6>
            NVIC_DisableIRQ(UART0_IRQn);
23001c72:	02d00513          	li	a0,45
            NVIC_DisableIRQ(UART1_IRQn);
23001c76:	519000ef          	jal	ra,2300298e <clic_disable_interrupt>
23001c7a:	bfe1                	j	23001c52 <uart_control+0x66>
            if ((uint32_t)args & (1 << offset))
23001c7c:	012a17b3          	sll	a5,s4,s2
23001c80:	8fe5                	and	a5,a5,s1
23001c82:	c791                	beqz	a5,23001c8e <uart_control+0xa2>
                UART_IntMask(uart_device->id, offset, MASK);
23001c84:	4605                	li	a2,1
23001c86:	0ff97593          	andi	a1,s2,255
23001c8a:	151010ef          	jal	ra,230035da <UART_IntMask>
            offset++;
23001c8e:	0905                	addi	s2,s2,1
23001c90:	bfe1                	j	23001c68 <uart_control+0x7c>
        else if (uart_device->id == UART1_ID)
23001c92:	4785                	li	a5,1
23001c94:	faf51fe3          	bne	a0,a5,23001c52 <uart_control+0x66>
            NVIC_DisableIRQ(UART1_IRQn);
23001c98:	02e00513          	li	a0,46
23001c9c:	bfe9                	j	23001c76 <uart_control+0x8a>
        UART_Disable(uart_device->id, UART_TXRX);
23001c9e:	03454503          	lbu	a0,52(a0)
23001ca2:	4589                	li	a1,2
23001ca4:	0c5010ef          	jal	ra,23003568 <UART_Disable>
        break;
23001ca8:	b76d                	j	23001c52 <uart_control+0x66>
        UART_Disable(uart_device->id, UART_TXRX);
23001caa:	03454503          	lbu	a0,52(a0)
23001cae:	4589                	li	a1,2
23001cb0:	0b9010ef          	jal	ra,23003568 <UART_Disable>
        uint32_t uart_clk = peripheral_clock_get(PERIPHERAL_CLOCK_UART);
23001cb4:	4501                	li	a0,0
23001cb6:	ee6ff0ef          	jal	ra,2300139c <peripheral_clock_get>
        uart_cfg.uartClk = uart_clk;
23001cba:	c62a                	sw	a0,12(sp)
        uart_cfg.baudRate = cfg->baudrate;
23001cbc:	4098                	lw	a4,0(s1)
        uart_cfg.parity = cfg->parity;
23001cbe:	0064c783          	lbu	a5,6(s1)
        UART_Init(uart_device->id, &uart_cfg);
23001cc2:	03444503          	lbu	a0,52(s0)
        uart_cfg.baudRate = cfg->baudrate;
23001cc6:	c83a                	sw	a4,16(sp)
        uart_cfg.dataBits = cfg->databits;
23001cc8:	0044d703          	lhu	a4,4(s1)
        UART_Init(uart_device->id, &uart_cfg);
23001ccc:	006c                	addi	a1,sp,12
        uart_cfg.parity = cfg->parity;
23001cce:	00f10b23          	sb	a5,22(sp)
        uart_cfg.dataBits = cfg->databits;
23001cd2:	00e11a23          	sh	a4,20(sp)
        uart_cfg.ctsFlowControl = UART_CTS_FLOWCONTROL_ENABLE;
23001cd6:	00010ba3          	sb	zero,23(sp)
        uart_cfg.rtsSoftwareControl = UART_RTS_FLOWCONTROL_ENABLE;
23001cda:	00010ca3          	sb	zero,25(sp)
        uart_cfg.txSoftwareControl = UART_TX_SWCONTROL_ENABLE;
23001cde:	00011d23          	sh	zero,26(sp)
        uart_cfg.rxLinMode = UART_RX_LINMODE_ENABLE;
23001ce2:	00011e23          	sh	zero,28(sp)
        uart_cfg.byteBitInverse = UART_MSB_FIRST_ENABLE;
23001ce6:	00010f23          	sb	zero,30(sp)
        UART_Init(uart_device->id, &uart_cfg);
23001cea:	6b0010ef          	jal	ra,2300339a <UART_Init>
        if (uart_device->id == UART0_ID)
23001cee:	03444783          	lbu	a5,52(s0)
23001cf2:	eb89                	bnez	a5,23001d04 <uart_control+0x118>
            Interrupt_Handler_Register(UART0_IRQn, UART0_IRQ);
23001cf4:	220155b7          	lui	a1,0x22015
23001cf8:	1e458593          	addi	a1,a1,484 # 220151e4 <UART0_IRQ>
23001cfc:	02d00513          	li	a0,45
23001d00:	64f000ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
        if (uart_device->id == UART1_ID)
23001d04:	03444703          	lbu	a4,52(s0)
23001d08:	4785                	li	a5,1
23001d0a:	00f71a63          	bne	a4,a5,23001d1e <uart_control+0x132>
            Interrupt_Handler_Register(UART1_IRQn, UART1_IRQ);
23001d0e:	230025b7          	lui	a1,0x23002
23001d12:	e8258593          	addi	a1,a1,-382 # 23001e82 <UART1_IRQ>
23001d16:	02e00513          	li	a0,46
23001d1a:	635000ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
        UART_Enable(uart_device->id, UART_TXRX);
23001d1e:	03444503          	lbu	a0,52(s0)
23001d22:	4589                	li	a1,2
23001d24:	011010ef          	jal	ra,23003534 <UART_Enable>
        break;
23001d28:	b72d                	j	23001c52 <uart_control+0x66>
        uart_device->tx_dma = (struct device *)args;
23001d2a:	c030                	sw	a2,64(s0)
        break;
23001d2c:	b71d                	j	23001c52 <uart_control+0x66>
        uart_device->rx_dma = (struct device *)args;
23001d2e:	c070                	sw	a2,68(s0)
        break;
23001d30:	b70d                	j	23001c52 <uart_control+0x66>
        uint32_t tmpVal = BL_RD_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0);
23001d32:	03454783          	lbu	a5,52(a0)
23001d36:	4000a737          	lui	a4,0x4000a
23001d3a:	08070713          	addi	a4,a4,128 # 4000a080 <__ram_load_addr+0x1cffd15c>
23001d3e:	07a2                	slli	a5,a5,0x8
23001d40:	97ba                	add	a5,a5,a4
23001d42:	4398                	lw	a4,0(a5)
        tmpVal = BL_CLR_REG_BIT(tmpVal,UART_DMA_TX_EN);
23001d44:	9b79                	andi	a4,a4,-2
        BL_WR_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0,tmpVal);
23001d46:	c398                	sw	a4,0(a5)
        break;
23001d48:	b729                	j	23001c52 <uart_control+0x66>
        uint32_t tmpVal = BL_RD_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0);
23001d4a:	03454783          	lbu	a5,52(a0)
23001d4e:	4000a737          	lui	a4,0x4000a
23001d52:	08070713          	addi	a4,a4,128 # 4000a080 <__ram_load_addr+0x1cffd15c>
23001d56:	07a2                	slli	a5,a5,0x8
23001d58:	97ba                	add	a5,a5,a4
23001d5a:	4398                	lw	a4,0(a5)
        tmpVal = BL_CLR_REG_BIT(tmpVal,UART_DMA_RX_EN);
23001d5c:	9b75                	andi	a4,a4,-3
        BL_WR_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0,tmpVal);
23001d5e:	b7e5                	j	23001d46 <uart_control+0x15a>
        uint32_t tmpVal = BL_RD_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0);
23001d60:	03454783          	lbu	a5,52(a0)
23001d64:	4000a737          	lui	a4,0x4000a
23001d68:	08070713          	addi	a4,a4,128 # 4000a080 <__ram_load_addr+0x1cffd15c>
23001d6c:	07a2                	slli	a5,a5,0x8
23001d6e:	97ba                	add	a5,a5,a4
23001d70:	4398                	lw	a4,0(a5)
        tmpVal = BL_SET_REG_BIT(tmpVal,UART_DMA_TX_EN);
23001d72:	00176713          	ori	a4,a4,1
        BL_WR_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0,tmpVal);
23001d76:	bfc1                	j	23001d46 <uart_control+0x15a>
        uint32_t tmpVal = BL_RD_REG(UART0_BASE+uart_device->id*0x100,UART_FIFO_CONFIG_0);
23001d78:	03454783          	lbu	a5,52(a0)
23001d7c:	4000a737          	lui	a4,0x4000a
23001d80:	08070713          	addi	a4,a4,128 # 4000a080 <__ram_load_addr+0x1cffd15c>
23001d84:	07a2                	slli	a5,a5,0x8
23001d86:	97ba                	add	a5,a5,a4
23001d88:	4398                	lw	a4,0(a5)
        tmpVal = BL_SET_REG_BIT(tmpVal,UART_DMA_RX_EN);
23001d8a:	00276713          	ori	a4,a4,2
23001d8e:	bf65                	j	23001d46 <uart_control+0x15a>
        return UART_GetTxFifoCount(uart_device->id);
23001d90:	03454503          	lbu	a0,52(a0)
23001d94:	0cf010ef          	jal	ra,23003662 <UART_GetTxFifoCount>
}
23001d98:	50f2                	lw	ra,60(sp)
23001d9a:	5462                	lw	s0,56(sp)
23001d9c:	54d2                	lw	s1,52(sp)
23001d9e:	5942                	lw	s2,48(sp)
23001da0:	59b2                	lw	s3,44(sp)
23001da2:	5a22                	lw	s4,40(sp)
23001da4:	6121                	addi	sp,sp,64
23001da6:	8082                	ret
        return UART_GetRxFifoCount(uart_device->id);
23001da8:	03454503          	lbu	a0,52(a0)
23001dac:	ff014097          	auipc	ra,0xff014
23001db0:	ec6080e7          	jalr	-314(ra) # 22015c72 <UART_GetRxFifoCount>
23001db4:	b7d5                	j	23001d98 <uart_control+0x1ac>
    return 0;
23001db6:	4501                	li	a0,0
}
23001db8:	8082                	ret

23001dba <uart_write>:
 * @return int 
 */
int uart_write(struct device *dev, uint32_t pos, const void *buffer, uint32_t size)
{
    uart_device_t *uart_device = (uart_device_t *)dev;
    if (dev->oflag & DEVICE_OFLAG_DMA_TX)
23001dba:	01655783          	lhu	a5,22(a0)
{
23001dbe:	1141                	addi	sp,sp,-16
23001dc0:	c606                	sw	ra,12(sp)
23001dc2:	c422                	sw	s0,8(sp)
23001dc4:	c226                	sw	s1,4(sp)
    if (dev->oflag & DEVICE_OFLAG_DMA_TX)
23001dc6:	8bc1                	andi	a5,a5,16
{
23001dc8:	85b2                	mv	a1,a2
    if (dev->oflag & DEVICE_OFLAG_DMA_TX)
23001dca:	cbb9                	beqz	a5,23001e20 <uart_write+0x66>
    {
        struct device *dma_ch = (struct device *)uart_device->tx_dma;
23001dcc:	4120                	lw	s0,64(a0)
        if (!dma_ch)
            return -1;
23001dce:	54fd                	li	s1,-1
        if (!dma_ch)
23001dd0:	c00d                	beqz	s0,23001df2 <uart_write+0x38>
            
        if(uart_device->id == 0)
23001dd2:	03454783          	lbu	a5,52(a0)
23001dd6:	e785                	bnez	a5,23001dfe <uart_write+0x44>
        {
            dma_reload(dma_ch, (uint32_t)buffer, (uint32_t)DMA_ADDR_UART0_TDR, size);
23001dd8:	4000a637          	lui	a2,0x4000a
23001ddc:	08860613          	addi	a2,a2,136 # 4000a088 <__ram_load_addr+0x1cffd164>
23001de0:	8522                	mv	a0,s0
23001de2:	f6aff0ef          	jal	ra,2300154c <dma_reload>
        else if(uart_device->id == 1)
        {
            dma_reload(dma_ch, (uint32_t)buffer, (uint32_t)DMA_ADDR_UART1_TDR, size);
            dma_channel_start(dma_ch);
        }
        return 0;
23001de6:	4481                	li	s1,0
            dma_channel_start(dma_ch);
23001de8:	4601                	li	a2,0
23001dea:	45c5                	li	a1,17
23001dec:	8522                	mv	a0,s0
23001dee:	5cb020ef          	jal	ra,23004bb8 <device_control>
    }
    return UART_SendData(uart_device->id, (uint8_t *)buffer, size);
}
23001df2:	40b2                	lw	ra,12(sp)
23001df4:	4422                	lw	s0,8(sp)
23001df6:	8526                	mv	a0,s1
23001df8:	4492                	lw	s1,4(sp)
23001dfa:	0141                	addi	sp,sp,16
23001dfc:	8082                	ret
        else if(uart_device->id == 1)
23001dfe:	4705                	li	a4,1
        return 0;
23001e00:	4481                	li	s1,0
        else if(uart_device->id == 1)
23001e02:	fee798e3          	bne	a5,a4,23001df2 <uart_write+0x38>
            dma_reload(dma_ch, (uint32_t)buffer, (uint32_t)DMA_ADDR_UART1_TDR, size);
23001e06:	4000a637          	lui	a2,0x4000a
23001e0a:	18860613          	addi	a2,a2,392 # 4000a188 <__ram_load_addr+0x1cffd264>
23001e0e:	8522                	mv	a0,s0
23001e10:	f3cff0ef          	jal	ra,2300154c <dma_reload>
            dma_channel_start(dma_ch);
23001e14:	4601                	li	a2,0
23001e16:	45c5                	li	a1,17
23001e18:	8522                	mv	a0,s0
23001e1a:	59f020ef          	jal	ra,23004bb8 <device_control>
23001e1e:	bfd1                	j	23001df2 <uart_write+0x38>
    return UART_SendData(uart_device->id, (uint8_t *)buffer, size);
23001e20:	03454503          	lbu	a0,52(a0)
23001e24:	8636                	mv	a2,a3
23001e26:	7f2010ef          	jal	ra,23003618 <UART_SendData>
23001e2a:	84aa                	mv	s1,a0
23001e2c:	b7d9                	j	23001df2 <uart_write+0x38>

23001e2e <uart_register>:
    if(UART_MAX_INDEX == 0)
    return -DEVICE_EINVAL;

    dev = &(uartx_device[index].parent);

    dev->open = uart_open;
23001e2e:	04800793          	li	a5,72
23001e32:	02f507b3          	mul	a5,a0,a5
23001e36:	42024537          	lui	a0,0x42024
23001e3a:	1cc50513          	addi	a0,a0,460 # 420241cc <uartx_device>
23001e3e:	953e                	add	a0,a0,a5
23001e40:	230027b7          	lui	a5,0x23002
23001e44:	af078793          	addi	a5,a5,-1296 # 23001af0 <uart_open>
23001e48:	cd1c                	sw	a5,24(a0)
    dev->close = uart_close;
23001e4a:	230027b7          	lui	a5,0x23002
23001e4e:	ada78793          	addi	a5,a5,-1318 # 23001ada <uart_close>
23001e52:	cd5c                	sw	a5,28(a0)
    dev->control = uart_control;
23001e54:	230027b7          	lui	a5,0x23002
23001e58:	bec78793          	addi	a5,a5,-1044 # 23001bec <uart_control>
23001e5c:	d11c                	sw	a5,32(a0)
    dev->write = uart_write;
23001e5e:	230027b7          	lui	a5,0x23002
23001e62:	dba78793          	addi	a5,a5,-582 # 23001dba <uart_write>
23001e66:	d15c                	sw	a5,36(a0)
    dev->read = uart_read;
23001e68:	220157b7          	lui	a5,0x22015
23001e6c:	00078793          	mv	a5,a5
23001e70:	d51c                	sw	a5,40(a0)

    dev->status = DEVICE_UNREGISTER;
23001e72:	20000793          	li	a5,512
23001e76:	00f51a23          	sh	a5,20(a0)
    dev->type = DEVICE_CLASS_UART;
    dev->handle = NULL;
23001e7a:	02052823          	sw	zero,48(a0)

    return device_register(dev, name, flag);
23001e7e:	4630206f          	j	23004ae0 <device_register>

23001e82 <UART1_IRQ>:
 * @brief 
 * 
 */
void UART1_IRQ(void)
{
    uart_isr(&uartx_device[UART1_INDEX]);
23001e82:	42024537          	lui	a0,0x42024
23001e86:	21450513          	addi	a0,a0,532 # 42024214 <uartx_device+0x48>
23001e8a:	ff013317          	auipc	t1,0xff013
23001e8e:	1f430067          	jr	500(t1) # 2201507e <uart_isr>

23001e92 <usb_ep_is_enabled>:
static uint8_t usb_ep_is_enabled(uint8_t ep)
{
    uint8_t ep_idx = USB_EP_GET_IDX(ep);

    /* Check if ep enabled */
    if ((USB_EP_DIR_IS_OUT(ep)) &&
23001e92:	07f57793          	andi	a5,a0,127
23001e96:	0562                	slli	a0,a0,0x18
23001e98:	420246b7          	lui	a3,0x42024
23001e9c:	8561                	srai	a0,a0,0x18
23001e9e:	32068693          	addi	a3,a3,800 # 42024320 <usb_fs_device>
23001ea2:	00054b63          	bltz	a0,23001eb8 <usb_ep_is_enabled+0x26>
            usb_fs_device.out_ep[ep_idx].ep_ena)
23001ea6:	07ad                	addi	a5,a5,11
23001ea8:	00479713          	slli	a4,a5,0x4
23001eac:	9736                	add	a4,a4,a3
    if ((USB_EP_DIR_IS_OUT(ep)) &&
23001eae:	00874503          	lbu	a0,8(a4)
    {
        return 1;
23001eb2:	00a03533          	snez	a0,a0
    {
        return 1;
    }

    return 0;
}
23001eb6:	8082                	ret
             usb_fs_device.in_ep[ep_idx].ep_ena)
23001eb8:	078d                	addi	a5,a5,3
23001eba:	0792                	slli	a5,a5,0x4
23001ebc:	97b6                	add	a5,a5,a3
    else if ((USB_EP_DIR_IS_IN(ep)) &&
23001ebe:	0087c503          	lbu	a0,8(a5) # 22015008 <uart_read+0x8>
23001ec2:	bfc5                	j	23001eb2 <usb_ep_is_enabled+0x20>

23001ec4 <usb_control>:
 * @return int
 */
int usb_control(struct device *dev, int cmd, void *args)
{
    struct usb_dc_device *usb_device = (struct usb_dc_device *)dev;
    switch (cmd)
23001ec4:	15fd                	addi	a1,a1,-1
23001ec6:	02100793          	li	a5,33
23001eca:	10b7e163          	bltu	a5,a1,23001fcc <usb_control+0x108>
23001ece:	230067b7          	lui	a5,0x23006
23001ed2:	e5c78793          	addi	a5,a5,-420 # 23005e5c <af_pin_table+0x2b0>
23001ed6:	058a                	slli	a1,a1,0x2
23001ed8:	95be                	add	a1,a1,a5
23001eda:	419c                	lw	a5,0(a1)
{
23001edc:	1101                	addi	sp,sp,-32
23001ede:	cc22                	sw	s0,24(sp)
23001ee0:	ce06                	sw	ra,28(sp)
23001ee2:	ca26                	sw	s1,20(sp)
23001ee4:	c84a                	sw	s2,16(sp)
23001ee6:	c64e                	sw	s3,12(sp)
23001ee8:	c452                	sw	s4,8(sp)
23001eea:	8432                	mv	s0,a2
    switch (cmd)
23001eec:	8782                	jr	a5
    {
        case DEVICE_CTRL_SET_INT /* constant-expression */:
        {
            uint32_t offset = __builtin_ctz((uint32_t)args);
23001eee:	8532                	mv	a0,a2
23001ef0:	ad4fe0ef          	jal	ra,230001c4 <__ctzsi2>
23001ef4:	84aa                	mv	s1,a0
            while (offset < 24)
23001ef6:	49dd                	li	s3,23
            {
                if ((uint32_t)args & (1 << offset))
23001ef8:	4a05                	li	s4,1
            while (offset < 24)
23001efa:	0099f463          	bgeu	s3,s1,23001f02 <usb_control+0x3e>
            USB_Set_EPx_RX_DMA_Interface_Config(((uint32_t)args) & 0x7f,ENABLE);
            break;
        default:
            break;
    }
    return 0;
23001efe:	4501                	li	a0,0
23001f00:	a051                	j	23001f84 <usb_control+0xc0>
                if ((uint32_t)args & (1 << offset))
23001f02:	009a17b3          	sll	a5,s4,s1
23001f06:	8fe1                	and	a5,a5,s0
23001f08:	cb99                	beqz	a5,23001f1e <usb_control+0x5a>
                    USB_IntEn(offset, ENABLE);
23001f0a:	0ff4f913          	andi	s2,s1,255
23001f0e:	4585                	li	a1,1
23001f10:	854a                	mv	a0,s2
23001f12:	4d1010ef          	jal	ra,23003be2 <USB_IntEn>
                    USB_IntMask(offset, UNMASK); //11
23001f16:	4581                	li	a1,0
23001f18:	854a                	mv	a0,s2
23001f1a:	511010ef          	jal	ra,23003c2a <USB_IntMask>
                offset++;
23001f1e:	0485                	addi	s1,s1,1
23001f20:	bfe9                	j	23001efa <usb_control+0x36>
            USB_Set_Device_Addr(((uint32_t)args) & 0x7f);
23001f22:	07f67513          	andi	a0,a2,127
23001f26:	00b010ef          	jal	ra,23003730 <USB_Set_Device_Addr>
            return 0;
23001f2a:	bfd1                	j	23001efe <usb_control+0x3a>
            USB_Set_EPx_Status(USB_EP_GET_IDX(((uint32_t)args) & 0x7f), USB_EP_STATUS_ACK);
23001f2c:	4581                	li	a1,0
            USB_Set_EPx_Status(USB_EP_GET_IDX(((uint32_t)args) & 0x7f), USB_EP_STATUS_NACK);
23001f2e:	07f47513          	andi	a0,s0,127
23001f32:	3d5010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
            return 0;
23001f36:	b7e1                	j	23001efe <usb_control+0x3a>
            USB_Set_EPx_Status(USB_EP_GET_IDX(((uint32_t)args) & 0x7f), USB_EP_STATUS_NACK);
23001f38:	4585                	li	a1,1
23001f3a:	bfd5                	j	23001f2e <usb_control+0x6a>
            uint8_t ep_idx = USB_EP_GET_IDX(((uint32_t)args) & 0x7f);
23001f3c:	07f67413          	andi	s0,a2,127
                USB_Set_EPx_Status(ep_idx, USB_EP_STATUS_STALL);
23001f40:	8522                	mv	a0,s0
23001f42:	4589                	li	a1,2
23001f44:	3c3010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
                usb_fs_device.out_ep[ep_idx].is_stalled = 1U;
23001f48:	042d                	addi	s0,s0,11
23001f4a:	420247b7          	lui	a5,0x42024
23001f4e:	32078793          	addi	a5,a5,800 # 42024320 <usb_fs_device>
23001f52:	0412                	slli	s0,s0,0x4
23001f54:	943e                	add	s0,s0,a5
23001f56:	4785                	li	a5,1
23001f58:	c45c                	sw	a5,12(s0)
        return 0;
23001f5a:	b755                	j	23001efe <usb_control+0x3a>
            uint8_t ep_idx = USB_EP_GET_IDX(((uint32_t)args) & 0x7f);
23001f5c:	07f67413          	andi	s0,a2,127
                USB_Set_EPx_Status(ep_idx, USB_EP_STATUS_NSTALL);
23001f60:	8522                	mv	a0,s0
23001f62:	458d                	li	a1,3
23001f64:	3a3010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
                usb_fs_device.out_ep[ep_idx].is_stalled = 0;
23001f68:	042d                	addi	s0,s0,11
23001f6a:	420247b7          	lui	a5,0x42024
23001f6e:	0412                	slli	s0,s0,0x4
23001f70:	32078793          	addi	a5,a5,800 # 42024320 <usb_fs_device>
23001f74:	943e                	add	s0,s0,a5
23001f76:	00042623          	sw	zero,12(s0)
        return 0;
23001f7a:	b751                	j	23001efe <usb_control+0x3a>
            return USB_Get_EPx_TX_FIFO_CNT(((uint32_t)args) & 0x7f);
23001f7c:	07f67513          	andi	a0,a2,127
23001f80:	028020ef          	jal	ra,23003fa8 <USB_Get_EPx_TX_FIFO_CNT>
}
23001f84:	40f2                	lw	ra,28(sp)
23001f86:	4462                	lw	s0,24(sp)
23001f88:	44d2                	lw	s1,20(sp)
23001f8a:	4942                	lw	s2,16(sp)
23001f8c:	49b2                	lw	s3,12(sp)
23001f8e:	4a22                	lw	s4,8(sp)
23001f90:	6105                	addi	sp,sp,32
23001f92:	8082                	ret
            return USB_Get_EPx_RX_FIFO_CNT(((uint32_t)args) & 0x7f);
23001f94:	07f67513          	andi	a0,a2,127
23001f98:	07e020ef          	jal	ra,23004016 <USB_Get_EPx_RX_FIFO_CNT>
23001f9c:	b7e5                	j	23001f84 <usb_control+0xc0>
            return USB_Is_EPx_RDY_Free(((uint32_t)args) & 0x7f);
23001f9e:	07f67513          	andi	a0,a2,127
23001fa2:	11b010ef          	jal	ra,230038bc <USB_Is_EPx_RDY_Free>
23001fa6:	bff9                	j	23001f84 <usb_control+0xc0>
            usb_device->tx_dma = (struct device *)args;
23001fa8:	12c52c23          	sw	a2,312(a0)
            break;
23001fac:	bf89                	j	23001efe <usb_control+0x3a>
            usb_device->rx_dma = (struct device *)args;
23001fae:	12c52e23          	sw	a2,316(a0)
            break;
23001fb2:	b7b1                	j	23001efe <usb_control+0x3a>
            USB_Set_EPx_TX_DMA_Interface_Config(((uint32_t)args) & 0x7f,ENABLE);
23001fb4:	4585                	li	a1,1
23001fb6:	07f67513          	andi	a0,a2,127
23001fba:	617010ef          	jal	ra,23003dd0 <USB_Set_EPx_TX_DMA_Interface_Config>
            break;
23001fbe:	b781                	j	23001efe <usb_control+0x3a>
            USB_Set_EPx_RX_DMA_Interface_Config(((uint32_t)args) & 0x7f,ENABLE);
23001fc0:	4585                	li	a1,1
23001fc2:	07f67513          	andi	a0,a2,127
23001fc6:	6f7010ef          	jal	ra,23003ebc <USB_Set_EPx_RX_DMA_Interface_Config>
            break;
23001fca:	bf15                	j	23001efe <usb_control+0x3a>
    return 0;
23001fcc:	4501                	li	a0,0
}
23001fce:	8082                	ret

23001fd0 <usb_write>:

int usb_write(struct device *dev, uint32_t pos, const void *buffer, uint32_t size)
{
23001fd0:	1101                	addi	sp,sp,-32
23001fd2:	c84a                	sw	s2,16(sp)
    struct usb_dc_device *usb_device = (struct usb_dc_device *)dev;
    uint8_t ep_idx = USB_EP_GET_IDX(pos);

    if(usb_device->in_ep[ep_idx].ep_cfg.ep_type == USBD_EP_TYPE_ISOC)
23001fd4:	07f5f913          	andi	s2,a1,127
23001fd8:	00390793          	addi	a5,s2,3
23001fdc:	0792                	slli	a5,a5,0x4
23001fde:	97aa                	add	a5,a5,a0
{
23001fe0:	ce06                	sw	ra,28(sp)
23001fe2:	cc22                	sw	s0,24(sp)
23001fe4:	ca26                	sw	s1,20(sp)
23001fe6:	c64e                	sw	s3,12(sp)
    if(usb_device->in_ep[ep_idx].ep_cfg.ep_type == USBD_EP_TYPE_ISOC)
23001fe8:	0147c703          	lbu	a4,20(a5)
23001fec:	4785                	li	a5,1
23001fee:	06f71563          	bne	a4,a5,23002058 <usb_write+0x88>
23001ff2:	84aa                	mv	s1,a0
    {
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x10;

        dma_channel_stop(usb_device->tx_dma);
23001ff4:	13852503          	lw	a0,312(a0)
23001ff8:	89b2                	mv	s3,a2
23001ffa:	45c9                	li	a1,18
23001ffc:	4601                	li	a2,0
23001ffe:	8436                	mv	s0,a3
23002000:	3b9020ef          	jal	ra,23004bb8 <device_control>
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x10;
23002004:	0912                	slli	s2,s2,0x4
23002006:	4000e7b7          	lui	a5,0x4000e
        usb_lli_list.src_addr = (uint32_t)buffer;
2300200a:	42024637          	lui	a2,0x42024
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x10;
2300200e:	b0878793          	addi	a5,a5,-1272 # 4000db08 <__ram_load_addr+0x1d000be4>
        usb_lli_list.src_addr = (uint32_t)buffer;
23002012:	46060713          	addi	a4,a2,1120 # 42024460 <usb_lli_list>
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x10;
23002016:	993e                	add	s2,s2,a5
        usb_lli_list.dst_addr = usb_ep_addr;
        usb_lli_list.cfg.bits.TransferSize = size;
23002018:	475c                	lw	a5,12(a4)
2300201a:	01441693          	slli	a3,s0,0x14
2300201e:	82d1                	srli	a3,a3,0x14
23002020:	75fd                	lui	a1,0xfffff
23002022:	8fed                	and	a5,a5,a1
23002024:	8fd5                	or	a5,a5,a3
        usb_lli_list.cfg.bits.DI = 0;
        usb_lli_list.cfg.bits.SI = 1;
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_16BYTE;
23002026:	f3fe56b7          	lui	a3,0xf3fe5
2300202a:	16fd                	addi	a3,a3,-1
2300202c:	8ff5                	and	a5,a5,a3
        usb_lli_list.cfg.bits.DBSize = DMA_BURST_1BYTE;
        device_control(usb_device->tx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
2300202e:	1384a503          	lw	a0,312(s1)
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_16BYTE;
23002032:	040036b7          	lui	a3,0x4003
23002036:	8fd5                	or	a5,a5,a3
        device_control(usb_device->tx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
23002038:	46060613          	addi	a2,a2,1120
2300203c:	45cd                	li	a1,19
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_16BYTE;
2300203e:	c75c                	sw	a5,12(a4)
        usb_lli_list.src_addr = (uint32_t)buffer;
23002040:	01372023          	sw	s3,0(a4)
        usb_lli_list.dst_addr = usb_ep_addr;
23002044:	01272223          	sw	s2,4(a4)
        device_control(usb_device->tx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
23002048:	371020ef          	jal	ra,23004bb8 <device_control>
        dma_channel_start(usb_device->tx_dma);
2300204c:	1384a503          	lw	a0,312(s1)
23002050:	4601                	li	a2,0
23002052:	45c5                	li	a1,17
23002054:	365020ef          	jal	ra,23004bb8 <device_control>
    else
    {

    }
    return 0;
}
23002058:	40f2                	lw	ra,28(sp)
2300205a:	4462                	lw	s0,24(sp)
2300205c:	44d2                	lw	s1,20(sp)
2300205e:	4942                	lw	s2,16(sp)
23002060:	49b2                	lw	s3,12(sp)
23002062:	4501                	li	a0,0
23002064:	6105                	addi	sp,sp,32
23002066:	8082                	ret

23002068 <usb_read>:

int usb_read(struct device *dev, uint32_t pos, void *buffer, uint32_t size)
{
23002068:	1101                	addi	sp,sp,-32
2300206a:	c84a                	sw	s2,16(sp)
    struct usb_dc_device *usb_device = (struct usb_dc_device *)dev;
    uint8_t ep_idx = USB_EP_GET_IDX(pos);

    if(usb_device->out_ep[ep_idx].ep_cfg.ep_type == USBD_EP_TYPE_ISOC)
2300206c:	07f5f913          	andi	s2,a1,127
23002070:	00b90793          	addi	a5,s2,11
23002074:	0792                	slli	a5,a5,0x4
23002076:	97aa                	add	a5,a5,a0
{
23002078:	ce06                	sw	ra,28(sp)
2300207a:	cc22                	sw	s0,24(sp)
2300207c:	ca26                	sw	s1,20(sp)
2300207e:	c64e                	sw	s3,12(sp)
    if(usb_device->out_ep[ep_idx].ep_cfg.ep_type == USBD_EP_TYPE_ISOC)
23002080:	0147c703          	lbu	a4,20(a5)
23002084:	4785                	li	a5,1
23002086:	06f71763          	bne	a4,a5,230020f4 <usb_read+0x8c>
2300208a:	84aa                	mv	s1,a0
    {
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x1c;

        dma_channel_stop(usb_device->tx_dma);
2300208c:	13852503          	lw	a0,312(a0)
23002090:	89b2                	mv	s3,a2
23002092:	45c9                	li	a1,18
23002094:	4601                	li	a2,0
23002096:	8436                	mv	s0,a3
23002098:	321020ef          	jal	ra,23004bb8 <device_control>
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x1c;
2300209c:	47f1                	li	a5,28
2300209e:	02f90933          	mul	s2,s2,a5
230020a2:	4000e7b7          	lui	a5,0x4000e
        usb_lli_list.src_addr = usb_ep_addr;
230020a6:	42024637          	lui	a2,0x42024
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x1c;
230020aa:	b0878793          	addi	a5,a5,-1272 # 4000db08 <__ram_load_addr+0x1d000be4>
        usb_lli_list.src_addr = usb_ep_addr;
230020ae:	46060713          	addi	a4,a2,1120 # 42024460 <usb_lli_list>
        usb_lli_list.dst_addr = (uint32_t)buffer;
        usb_lli_list.cfg.bits.TransferSize = size;
230020b2:	01441693          	slli	a3,s0,0x14
230020b6:	82d1                	srli	a3,a3,0x14
230020b8:	75fd                	lui	a1,0xfffff
        usb_lli_list.cfg.bits.DI = 1;
        usb_lli_list.cfg.bits.SI = 0;
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_1BYTE;
        usb_lli_list.cfg.bits.DBSize = DMA_BURST_16BYTE;
        device_control(usb_device->rx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
230020ba:	13c4a503          	lw	a0,316(s1)
230020be:	46060613          	addi	a2,a2,1120
        uint32_t usb_ep_addr = USB_BASE + 0x308 + ep_idx * 0x1c;
230020c2:	993e                	add	s2,s2,a5
        usb_lli_list.cfg.bits.TransferSize = size;
230020c4:	475c                	lw	a5,12(a4)
        usb_lli_list.src_addr = usb_ep_addr;
230020c6:	01272023          	sw	s2,0(a4)
        usb_lli_list.dst_addr = (uint32_t)buffer;
230020ca:	01372223          	sw	s3,4(a4)
        usb_lli_list.cfg.bits.TransferSize = size;
230020ce:	8fed                	and	a5,a5,a1
230020d0:	8fd5                	or	a5,a5,a3
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_1BYTE;
230020d2:	f3fe56b7          	lui	a3,0xf3fe5
230020d6:	16fd                	addi	a3,a3,-1
230020d8:	8ff5                	and	a5,a5,a3
230020da:	080186b7          	lui	a3,0x8018
230020de:	8fd5                	or	a5,a5,a3
        device_control(usb_device->rx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
230020e0:	45cd                	li	a1,19
        usb_lli_list.cfg.bits.SBSize = DMA_BURST_1BYTE;
230020e2:	c75c                	sw	a5,12(a4)
        device_control(usb_device->rx_dma,DMA_CHANNEL_UPDATE,(void*)((uint32_t)&usb_lli_list));
230020e4:	2d5020ef          	jal	ra,23004bb8 <device_control>
        dma_channel_start(usb_device->rx_dma);
230020e8:	13c4a503          	lw	a0,316(s1)
230020ec:	4601                	li	a2,0
230020ee:	45c5                	li	a1,17
230020f0:	2c9020ef          	jal	ra,23004bb8 <device_control>
    else
    {
        
    }
    return 0;
}
230020f4:	40f2                	lw	ra,28(sp)
230020f6:	4462                	lw	s0,24(sp)
230020f8:	44d2                	lw	s1,20(sp)
230020fa:	4942                	lw	s2,16(sp)
230020fc:	49b2                	lw	s3,12(sp)
230020fe:	4501                	li	a0,0
23002100:	6105                	addi	sp,sp,32
23002102:	8082                	ret

23002104 <usb_open>:
{
23002104:	1101                	addi	sp,sp,-32
23002106:	cc22                	sw	s0,24(sp)
    tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
23002108:	40000437          	lui	s0,0x40000
2300210c:	22842783          	lw	a5,552(s0) # 40000228 <__ram_load_addr+0x1cff3304>
    tmpVal = BL_CLR_REG_BIT(tmpVal, GLB_PU_USB);
23002110:	ff800737          	lui	a4,0xff800
{
23002114:	ce06                	sw	ra,28(sp)
    USB_Config_Type usbCfg = {0};
23002116:	c402                	sw	zero,8(sp)
23002118:	00011623          	sh	zero,12(sp)
    tmpVal = BL_CLR_REG_BIT(tmpVal, GLB_PU_USB);
2300211c:	177d                	addi	a4,a4,-1
2300211e:	8ff9                	and	a5,a5,a4
    BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
23002120:	22f42423          	sw	a5,552(s0)
    mtimer_delay_ms(10);
23002124:	4529                	li	a0,10
23002126:	94dff0ef          	jal	ra,23001a72 <mtimer_delay_ms>
    tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
2300212a:	22842703          	lw	a4,552(s0)
    tmpVal = BL_SET_REG_BIT(tmpVal, GLB_PU_USB);
2300212e:	00800637          	lui	a2,0x800
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_PU_USB, 0);
23002132:	ff7006b7          	lui	a3,0xff700
    tmpVal = BL_SET_REG_BIT(tmpVal, GLB_PU_USB);
23002136:	8f51                	or	a4,a4,a2
    BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
23002138:	22e42423          	sw	a4,552(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
2300213c:	22842703          	lw	a4,552(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_PU_USB, 0);
23002140:	16fd                	addi	a3,a3,-1
    NVIC_DisableIRQ(USB_IRQn);
23002142:	02500513          	li	a0,37
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_PU_USB, 0);
23002146:	8f75                	and	a4,a4,a3
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
23002148:	22e42423          	sw	a4,552(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR_CONFIG);
2300214c:	22c42703          	lw	a4,556(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_BD_VTH, 7);
23002150:	07076713          	ori	a4,a4,112
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR_CONFIG, tmpVal);
23002154:	22e42623          	sw	a4,556(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
23002158:	22842783          	lw	a5,552(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_PU_USB, 1);
2300215c:	ffbef737          	lui	a4,0xffbef
23002160:	88f70713          	addi	a4,a4,-1905 # ffbee88f <__HeapLimit+0xbdbc288f>
23002164:	8fd1                	or	a5,a5,a2
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
23002166:	22f42423          	sw	a5,552(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
2300216a:	22842783          	lw	a5,552(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_ROUT_NMOS, 3);
2300216e:	8ff9                	and	a5,a5,a4
23002170:	00200737          	lui	a4,0x200
23002174:	33070713          	addi	a4,a4,816 # 200330 <HeapSize+0x1ff330>
23002178:	8fd9                	or	a5,a5,a4
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
2300217a:	22f42423          	sw	a5,552(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR_CONFIG);
2300217e:	88889737          	lui	a4,0x88889
23002182:	22c42783          	lw	a5,556(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_V_HYS_M, 2);
23002186:	f8070713          	addi	a4,a4,-128 # 88888f80 <__HeapLimit+0x4685cf80>
2300218a:	8ff9                	and	a5,a5,a4
2300218c:	22225737          	lui	a4,0x22225
23002190:	09a70713          	addi	a4,a4,154 # 2222509a <__tcm_code_end__+0x20edb2>
23002194:	8fd9                	or	a5,a5,a4
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR_CONFIG, tmpVal);
23002196:	22f42623          	sw	a5,556(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR_CONFIG);
2300219a:	22c42783          	lw	a5,556(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_ENUM, 1);
2300219e:	00100737          	lui	a4,0x100
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_BD_VTH, 7);
230021a2:	0707e793          	ori	a5,a5,112
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR_CONFIG, tmpVal);
230021a6:	22f42623          	sw	a5,556(s0)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
230021aa:	22842783          	lw	a5,552(s0)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_ENUM, 1);
230021ae:	8fd9                	or	a5,a5,a4
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
230021b0:	22f42423          	sw	a5,552(s0)
    NVIC_DisableIRQ(USB_IRQn);
230021b4:	7da000ef          	jal	ra,2300298e <clic_disable_interrupt>
    usbCfg.SoftwareCtrl = 1;
230021b8:	4405                	li	s0,1
    usbCfg.EnumOutEn = ENABLE;
230021ba:	004007b7          	lui	a5,0x400
230021be:	10178793          	addi	a5,a5,257 # 400101 <HeapSize+0x3ff101>
    USB_Set_Config(DISABLE, &usbCfg);
230021c2:	002c                	addi	a1,sp,8
230021c4:	4501                	li	a0,0
    usbCfg.EnumOutEn = ENABLE;
230021c6:	c43e                	sw	a5,8(sp)
    usbCfg.SoftwareCtrl = 1;
230021c8:	00811623          	sh	s0,12(sp)
    USB_Set_Config(DISABLE, &usbCfg);
230021cc:	4d4010ef          	jal	ra,230036a0 <USB_Set_Config>
    usb_fs_device.out_ep[0].ep_ena = 1U;
230021d0:	420247b7          	lui	a5,0x42024
230021d4:	32078793          	addi	a5,a5,800 # 42024320 <usb_fs_device>
    usb_fs_device.out_ep[0].ep_cfg.ep_mps = USB_CTRL_EP_MPS;
230021d8:	04000713          	li	a4,64
    usb_fs_device.out_ep[0].ep_ena = 1U;
230021dc:	0a878c23          	sb	s0,184(a5)
    usb_fs_device.in_ep[0].ep_ena = 1U;
230021e0:	02878c23          	sb	s0,56(a5)
    usb_fs_device.out_ep[0].ep_cfg.ep_mps = USB_CTRL_EP_MPS;
230021e4:	0ce79123          	sh	a4,194(a5)
    usb_fs_device.out_ep[0].ep_cfg.ep_type = USBD_EP_TYPE_CTRL;
230021e8:	0c078223          	sb	zero,196(a5)
    usb_fs_device.in_ep[0].ep_cfg.ep_mps = USB_CTRL_EP_MPS;
230021ec:	04e79123          	sh	a4,66(a5)
    usb_fs_device.in_ep[0].ep_cfg.ep_type = USBD_EP_TYPE_CTRL;
230021f0:	04078223          	sb	zero,68(a5)
    USB_IntEn(USB_INT_ALL, DISABLE);           //all
230021f4:	4581                	li	a1,0
230021f6:	02000513          	li	a0,32
230021fa:	1e9010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_RESET, ENABLE);          //1
230021fe:	4585                	li	a1,1
23002200:	4505                	li	a0,1
23002202:	1e1010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_EP0_SETUP_DONE, ENABLE); //5
23002206:	4585                	li	a1,1
23002208:	4515                	li	a0,5
2300220a:	1d9010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_EP0_IN_DONE, ENABLE);    //7
2300220e:	4585                	li	a1,1
23002210:	451d                	li	a0,7
23002212:	1d1010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_EP0_OUT_DONE, ENABLE);   //9
23002216:	4585                	li	a1,1
23002218:	4525                	li	a0,9
2300221a:	1c9010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_RESET_END, ENABLE);      //27
2300221e:	4585                	li	a1,1
23002220:	456d                	li	a0,27
23002222:	1c1010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntMask(USB_INT_ALL, MASK);              //all
23002226:	4585                	li	a1,1
23002228:	02000513          	li	a0,32
2300222c:	1ff010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_RESET, UNMASK);          //1
23002230:	4581                	li	a1,0
23002232:	4505                	li	a0,1
23002234:	1f7010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_EP0_SETUP_DONE, UNMASK); //5
23002238:	4581                	li	a1,0
2300223a:	4515                	li	a0,5
2300223c:	1ef010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_EP0_IN_DONE, UNMASK);    //7
23002240:	4581                	li	a1,0
23002242:	451d                	li	a0,7
23002244:	1e7010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_EP0_OUT_DONE, UNMASK);   //9
23002248:	4581                	li	a1,0
2300224a:	4525                	li	a0,9
2300224c:	1df010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_RESET_END, UNMASK);      //27
23002250:	4581                	li	a1,0
23002252:	456d                	li	a0,27
23002254:	1d7010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntEn(USB_INT_LPM_PACKET, ENABLE);
23002258:	4585                	li	a1,1
2300225a:	4575                	li	a0,29
2300225c:	187010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntEn(USB_INT_LPM_WAKEUP, ENABLE);
23002260:	4585                	li	a1,1
23002262:	4571                	li	a0,28
23002264:	17f010ef          	jal	ra,23003be2 <USB_IntEn>
    USB_IntMask(USB_INT_LPM_PACKET, UNMASK);
23002268:	4581                	li	a1,0
2300226a:	4575                	li	a0,29
2300226c:	1bf010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_LPM_WAKEUP, UNMASK);
23002270:	4581                	li	a1,0
23002272:	4571                	li	a0,28
23002274:	1b7010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_LPM_Enable();
23002278:	631010ef          	jal	ra,230040a8 <USB_LPM_Enable>
    USB_Set_LPM_Default_Response(USB_LPM_DEFAULT_RESP_ACK);
2300227c:	4501                	li	a0,0
2300227e:	609010ef          	jal	ra,23004086 <USB_Set_LPM_Default_Response>
    USB_Clr_IntStatus(USB_INT_ALL);
23002282:	02000513          	li	a0,32
23002286:	215010ef          	jal	ra,23003c9a <USB_Clr_IntStatus>
    Interrupt_Handler_Register(USB_IRQn, USB_IRQHandler);
2300228a:	230025b7          	lui	a1,0x23002
2300228e:	7e858593          	addi	a1,a1,2024 # 230027e8 <USB_IRQHandler>
23002292:	02500513          	li	a0,37
23002296:	0b9000ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
    NVIC_EnableIRQ(USB_IRQn);
2300229a:	02500513          	li	a0,37
2300229e:	6de000ef          	jal	ra,2300297c <clic_enable_interrupt>
    USB_Enable();
230022a2:	3d8010ef          	jal	ra,2300367a <USB_Enable>
}
230022a6:	4462                	lw	s0,24(sp)
230022a8:	40f2                	lw	ra,28(sp)
230022aa:	4501                	li	a0,0
230022ac:	6105                	addi	sp,sp,32
230022ae:	8082                	ret

230022b0 <usb_close>:
{
230022b0:	1141                	addi	sp,sp,-16
    NVIC_DisableIRQ(USB_IRQn);
230022b2:	02500513          	li	a0,37
{
230022b6:	c606                	sw	ra,12(sp)
    NVIC_DisableIRQ(USB_IRQn);
230022b8:	2dd9                	jal	2300298e <clic_disable_interrupt>
    USB_IntMask(USB_INT_LPM_WAKEUP, MASK);
230022ba:	4585                	li	a1,1
230022bc:	4571                	li	a0,28
230022be:	16d010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_IntMask(USB_INT_LPM_PACKET, MASK);
230022c2:	4585                	li	a1,1
230022c4:	4575                	li	a0,29
230022c6:	165010ef          	jal	ra,23003c2a <USB_IntMask>
    USB_Disable();
230022ca:	3c4010ef          	jal	ra,2300368e <USB_Disable>
    USB_Clr_IntStatus(USB_INT_ALL);
230022ce:	02000513          	li	a0,32
230022d2:	1c9010ef          	jal	ra,23003c9a <USB_Clr_IntStatus>
    tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
230022d6:	400007b7          	lui	a5,0x40000
230022da:	2287a703          	lw	a4,552(a5) # 40000228 <__ram_load_addr+0x1cff3304>
    tmpVal = BL_CLR_REG_BIT(tmpVal, GLB_PU_USB);
230022de:	ff8006b7          	lui	a3,0xff800
230022e2:	16fd                	addi	a3,a3,-1
230022e4:	8f75                	and	a4,a4,a3
    BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
230022e6:	22e7a423          	sw	a4,552(a5)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR);
230022ea:	2287a703          	lw	a4,552(a5)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_PU_USB, 0);
230022ee:	ff7006b7          	lui	a3,0xff700
230022f2:	16fd                	addi	a3,a3,-1
230022f4:	8f75                	and	a4,a4,a3
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR, tmpVal);
230022f6:	22e7a423          	sw	a4,552(a5)
        tmpVal = BL_RD_REG(GLB_BASE, GLB_USB_XCVR_CONFIG);
230022fa:	22c7a703          	lw	a4,556(a5)
    GLB_Set_USB_CLK(DISABLE);
230022fe:	4501                	li	a0,0
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal, GLB_USB_BD_VTH, 7);
23002300:	07076713          	ori	a4,a4,112
        BL_WR_REG(GLB_BASE, GLB_USB_XCVR_CONFIG, tmpVal);
23002304:	22e7a623          	sw	a4,556(a5)
    GLB_Set_USB_CLK(DISABLE);
23002308:	36d000ef          	jal	ra,23002e74 <GLB_Set_USB_CLK>
}
2300230c:	40b2                	lw	ra,12(sp)
2300230e:	4501                	li	a0,0
23002310:	0141                	addi	sp,sp,16
23002312:	8082                	ret

23002314 <usb_dc_register>:
    if (USB_MAX_INDEX == 0)
        return -DEVICE_EINVAL;

    dev = &(usb_fs_device.parent);

    dev->open = usb_open;
23002314:	23002737          	lui	a4,0x23002
23002318:	42024537          	lui	a0,0x42024
2300231c:	10470713          	addi	a4,a4,260 # 23002104 <usb_open>
23002320:	32050793          	addi	a5,a0,800 # 42024320 <usb_fs_device>
23002324:	cf98                	sw	a4,24(a5)
    dev->close = usb_close;
23002326:	23002737          	lui	a4,0x23002
2300232a:	2b070713          	addi	a4,a4,688 # 230022b0 <usb_close>
2300232e:	cfd8                	sw	a4,28(a5)
    dev->control = usb_control;
23002330:	23002737          	lui	a4,0x23002
23002334:	ec470713          	addi	a4,a4,-316 # 23001ec4 <usb_control>
23002338:	d398                	sw	a4,32(a5)
    dev->write = usb_write;
2300233a:	23002737          	lui	a4,0x23002
2300233e:	fd070713          	addi	a4,a4,-48 # 23001fd0 <usb_write>
23002342:	d3d8                	sw	a4,36(a5)
    dev->read = usb_read;
23002344:	23002737          	lui	a4,0x23002
23002348:	06870713          	addi	a4,a4,104 # 23002068 <usb_read>
2300234c:	d798                	sw	a4,40(a5)

    dev->status = DEVICE_UNREGISTER;
2300234e:	6705                	lui	a4,0x1
23002350:	a0070713          	addi	a4,a4,-1536 # a00 <__metal_chicken_bit+0xa00>
23002354:	00e79a23          	sh	a4,20(a5)
    dev->type = DEVICE_CLASS_USB;
    dev->handle = NULL;
23002358:	0207a823          	sw	zero,48(a5)

    return device_register(dev, name, flag);
2300235c:	32050513          	addi	a0,a0,800
23002360:	7800206f          	j	23004ae0 <device_register>

23002364 <usb_dc_ep_open>:
    uint8_t ep;
    EP_Config_Type epCfg;

    if (!ep_cfg)
    {
        return -1;
23002364:	557d                	li	a0,-1
    if (!ep_cfg)
23002366:	c1e5                	beqz	a1,23002446 <usb_dc_ep_open+0xe2>
{
23002368:	1101                	addi	sp,sp,-32
2300236a:	cc22                	sw	s0,24(sp)
2300236c:	ca26                	sw	s1,20(sp)
2300236e:	ce06                	sw	ra,28(sp)
23002370:	c84a                	sw	s2,16(sp)
    }
    ep = ep_cfg->ep_addr;
23002372:	0005c903          	lbu	s2,0(a1)

    uint8_t ep_idx = USB_EP_GET_IDX(ep);
23002376:	420244b7          	lui	s1,0x42024
2300237a:	0025d703          	lhu	a4,2(a1)
2300237e:	07f97413          	andi	s0,s2,127

    USB_DC_LOG_DBG("%s ep %x, mps %d, type %d\r\n", __func__, ep, ep_cfg->ep_mps, ep_cfg->ep_type);

    if (USB_EP_DIR_IS_OUT(ep))
23002382:	0962                	slli	s2,s2,0x18
23002384:	41895913          	srai	s2,s2,0x18
23002388:	32048493          	addi	s1,s1,800 # 42024320 <usb_fs_device>
2300238c:	04094263          	bltz	s2,230023d0 <usb_dc_ep_open+0x6c>
    {
        epCfg.dir = EP_OUT;
23002390:	4789                	li	a5,2
23002392:	00f10723          	sb	a5,14(sp)
        epCfg.EPMaxPacketSize = ep_cfg->ep_mps;
        usb_fs_device.out_ep[ep_idx].ep_cfg.ep_mps = ep_cfg->ep_mps;
23002396:	00b40793          	addi	a5,s0,11
2300239a:	0792                	slli	a5,a5,0x4
2300239c:	97a6                	add	a5,a5,s1
        epCfg.EPMaxPacketSize = ep_cfg->ep_mps;
2300239e:	00e11623          	sh	a4,12(sp)
        usb_fs_device.out_ep[ep_idx].ep_cfg.ep_mps = ep_cfg->ep_mps;
230023a2:	00e79923          	sh	a4,18(a5)
        usb_fs_device.out_ep[ep_idx].ep_cfg.ep_type = ep_cfg->ep_type;
230023a6:	0045c703          	lbu	a4,4(a1)
230023aa:	00e78a23          	sb	a4,20(a5)
        epCfg.EPMaxPacketSize = ep_cfg->ep_mps;
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps = ep_cfg->ep_mps;
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_type = ep_cfg->ep_type;
    }

    if (ep_idx)
230023ae:	c841                	beqz	s0,2300243e <usb_dc_ep_open+0xda>
    {
        switch (ep_cfg->ep_type)
230023b0:	0045c783          	lbu	a5,4(a1)
230023b4:	4705                	li	a4,1
230023b6:	06e78a63          	beq	a5,a4,2300242a <usb_dc_ep_open+0xc6>
230023ba:	cf95                	beqz	a5,230023f6 <usb_dc_ep_open+0x92>
230023bc:	4709                	li	a4,2
230023be:	06e78863          	beq	a5,a4,2300242e <usb_dc_ep_open+0xca>
230023c2:	470d                	li	a4,3
                break;
            case USBD_EP_TYPE_INTR:
                epCfg.type = USB_DC_EP_TYPE_INTR;
                break;
            default:
                return -1;
230023c4:	557d                	li	a0,-1
        switch (ep_cfg->ep_type)
230023c6:	04e79c63          	bne	a5,a4,2300241e <usb_dc_ep_open+0xba>
                epCfg.type = USB_DC_EP_TYPE_INTR;
230023ca:	000107a3          	sb	zero,15(sp)
                break;
230023ce:	a03d                	j	230023fc <usb_dc_ep_open+0x98>
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps = ep_cfg->ep_mps;
230023d0:	00340793          	addi	a5,s0,3
230023d4:	0792                	slli	a5,a5,0x4
230023d6:	97a6                	add	a5,a5,s1
        epCfg.EPMaxPacketSize = ep_cfg->ep_mps;
230023d8:	00e11623          	sh	a4,12(sp)
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps = ep_cfg->ep_mps;
230023dc:	00e79923          	sh	a4,18(a5)
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_type = ep_cfg->ep_type;
230023e0:	0045c703          	lbu	a4,4(a1)
        epCfg.dir = EP_IN;
230023e4:	4685                	li	a3,1
230023e6:	00d10723          	sb	a3,14(sp)
        usb_fs_device.in_ep[ep_idx].ep_cfg.ep_type = ep_cfg->ep_type;
230023ea:	00e78a23          	sb	a4,20(a5)
    if (ep_idx)
230023ee:	f069                	bnez	s0,230023b0 <usb_dc_ep_open+0x4c>
        {
            usb_fs_device.out_ep[ep_idx].ep_ena = 1U;
        }
        else
        {
            usb_fs_device.in_ep[ep_idx].ep_ena = 1U;
230023f0:	02d48c23          	sb	a3,56(s1)
230023f4:	a025                	j	2300241c <usb_dc_ep_open+0xb8>
                epCfg.type = USB_DC_EP_TYPE_CTRL;
230023f6:	4795                	li	a5,5
                epCfg.type = USB_DC_EP_TYPE_ISOC;
230023f8:	00f107a3          	sb	a5,15(sp)
        USB_Set_EPx_Config(ep_idx, &epCfg);
230023fc:	006c                	addi	a1,sp,12
230023fe:	8522                	mv	a0,s0
23002400:	0c3010ef          	jal	ra,23003cc2 <USB_Set_EPx_Config>
        if (USB_EP_DIR_IS_OUT(ep))
23002404:	02094763          	bltz	s2,23002432 <usb_dc_ep_open+0xce>
            USB_Set_EPx_Status(USB_EP_GET_IDX(ep), USB_EP_STATUS_ACK);
23002408:	8522                	mv	a0,s0
2300240a:	4581                	li	a1,0
2300240c:	6fa010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
            usb_fs_device.out_ep[ep_idx].ep_ena = 1U;
23002410:	042d                	addi	s0,s0,11
            usb_fs_device.in_ep[ep_idx].ep_ena = 1U;
23002412:	0412                	slli	s0,s0,0x4
23002414:	9426                	add	s0,s0,s1
23002416:	4785                	li	a5,1
23002418:	00f40423          	sb	a5,8(s0)
        }
    }

    return 0;
2300241c:	4501                	li	a0,0
}
2300241e:	40f2                	lw	ra,28(sp)
23002420:	4462                	lw	s0,24(sp)
23002422:	44d2                	lw	s1,20(sp)
23002424:	4942                	lw	s2,16(sp)
23002426:	6105                	addi	sp,sp,32
23002428:	8082                	ret
                epCfg.type = USB_DC_EP_TYPE_ISOC;
2300242a:	4789                	li	a5,2
2300242c:	b7f1                	j	230023f8 <usb_dc_ep_open+0x94>
                epCfg.type = USB_DC_EP_TYPE_BULK;
2300242e:	4791                	li	a5,4
23002430:	b7e1                	j	230023f8 <usb_dc_ep_open+0x94>
            USB_Set_EPx_Status(USB_EP_GET_IDX(ep), USB_EP_STATUS_NACK);
23002432:	8522                	mv	a0,s0
23002434:	4585                	li	a1,1
23002436:	6d0010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
            usb_fs_device.in_ep[ep_idx].ep_ena = 1U;
2300243a:	040d                	addi	s0,s0,3
2300243c:	bfd9                	j	23002412 <usb_dc_ep_open+0xae>
            usb_fs_device.out_ep[ep_idx].ep_ena = 1U;
2300243e:	4785                	li	a5,1
23002440:	0af48c23          	sb	a5,184(s1)
23002444:	bfe1                	j	2300241c <usb_dc_ep_open+0xb8>
}
23002446:	8082                	ret

23002448 <usb_dc_ep_is_stalled>:
{
    uint8_t ep_idx = USB_EP_GET_IDX(ep);

    if (!stalled)
    {
        return -1;
23002448:	557d                	li	a0,-1
    if (!stalled)
2300244a:	ce21                	beqz	a2,230024a2 <usb_dc_ep_is_stalled+0x5a>
{
2300244c:	1141                	addi	sp,sp,-16
2300244e:	c422                	sw	s0,8(sp)
23002450:	c226                	sw	s1,4(sp)
23002452:	07f5f413          	andi	s0,a1,127
23002456:	c606                	sw	ra,12(sp)
    }

    *stalled = 0U;
    if (USB_EP_DIR_IS_OUT(ep))
23002458:	05e2                	slli	a1,a1,0x18
    *stalled = 0U;
2300245a:	00060023          	sb	zero,0(a2) # 800000 <HeapSize+0x7ff000>
    if (USB_EP_DIR_IS_OUT(ep))
2300245e:	85e1                	srai	a1,a1,0x18
23002460:	84b2                	mv	s1,a2
    {
        if (USB_Get_EPx_Status(ep_idx) & USB_EP_STATUS_STALL && usb_fs_device.out_ep[ep_idx].is_stalled)
23002462:	8522                	mv	a0,s0
    if (USB_EP_DIR_IS_OUT(ep))
23002464:	0205c963          	bltz	a1,23002496 <usb_dc_ep_is_stalled+0x4e>
        if (USB_Get_EPx_Status(ep_idx) & USB_EP_STATUS_STALL && usb_fs_device.out_ep[ep_idx].is_stalled)
23002468:	6d0010ef          	jal	ra,23003b38 <USB_Get_EPx_Status>
2300246c:	8909                	andi	a0,a0,2
2300246e:	e519                	bnez	a0,2300247c <usb_dc_ep_is_stalled+0x34>
        if (USB_Get_EPx_Status(ep_idx) & USB_EP_STATUS_STALL && usb_fs_device.in_ep[ep_idx].is_stalled)
            *stalled = 1U;
    }

    return 0;
}
23002470:	40b2                	lw	ra,12(sp)
23002472:	4422                	lw	s0,8(sp)
23002474:	4492                	lw	s1,4(sp)
    return 0;
23002476:	4501                	li	a0,0
}
23002478:	0141                	addi	sp,sp,16
2300247a:	8082                	ret
        if (USB_Get_EPx_Status(ep_idx) & USB_EP_STATUS_STALL && usb_fs_device.out_ep[ep_idx].is_stalled)
2300247c:	042d                	addi	s0,s0,11
2300247e:	420247b7          	lui	a5,0x42024
23002482:	32078793          	addi	a5,a5,800 # 42024320 <usb_fs_device>
23002486:	0412                	slli	s0,s0,0x4
23002488:	943e                	add	s0,s0,a5
2300248a:	445c                	lw	a5,12(s0)
2300248c:	d3f5                	beqz	a5,23002470 <usb_dc_ep_is_stalled+0x28>
            *stalled = 1U;
2300248e:	4785                	li	a5,1
23002490:	00f48023          	sb	a5,0(s1)
23002494:	bff1                	j	23002470 <usb_dc_ep_is_stalled+0x28>
        if (USB_Get_EPx_Status(ep_idx) & USB_EP_STATUS_STALL && usb_fs_device.in_ep[ep_idx].is_stalled)
23002496:	6a2010ef          	jal	ra,23003b38 <USB_Get_EPx_Status>
2300249a:	8909                	andi	a0,a0,2
2300249c:	040d                	addi	s0,s0,3
2300249e:	f165                	bnez	a0,2300247e <usb_dc_ep_is_stalled+0x36>
230024a0:	bfc1                	j	23002470 <usb_dc_ep_is_stalled+0x28>
}
230024a2:	8082                	ret

230024a4 <usb_dc_ep_write>:
    uint32_t timeout = 0x00FFFFFF;
    uint32_t ep_tx_fifo_addr;

    ep_idx = USB_EP_GET_IDX(ep);
    /* Check if IN ep */
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN)
230024a4:	01859513          	slli	a0,a1,0x18
230024a8:	8561                	srai	a0,a0,0x18
    {
        return -1;
230024aa:	57fd                	li	a5,-1
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_IN)
230024ac:	0e055e63          	bgez	a0,230025a8 <usb_dc_ep_write+0x104>
{
230024b0:	1101                	addi	sp,sp,-32
    }

    /* Check if ep enabled */
    if (!usb_ep_is_enabled(ep))
230024b2:	852e                	mv	a0,a1
{
230024b4:	cc22                	sw	s0,24(sp)
230024b6:	ca26                	sw	s1,20(sp)
230024b8:	c64e                	sw	s3,12(sp)
230024ba:	c452                	sw	s4,8(sp)
230024bc:	c256                	sw	s5,4(sp)
230024be:	ce06                	sw	ra,28(sp)
230024c0:	c84a                	sw	s2,16(sp)
230024c2:	07f5f413          	andi	s0,a1,127
230024c6:	89ba                	mv	s3,a4
230024c8:	8ab6                	mv	s5,a3
230024ca:	8a32                	mv	s4,a2
230024cc:	84ae                	mv	s1,a1
    if (!usb_ep_is_enabled(ep))
230024ce:	9c5ff0ef          	jal	ra,23001e92 <usb_ep_is_enabled>
    {
        return -2;
230024d2:	57f9                	li	a5,-2
    if (!usb_ep_is_enabled(ep))
230024d4:	cd0d                	beqz	a0,2300250e <usb_dc_ep_write+0x6a>
230024d6:	01000937          	lui	s2,0x1000
230024da:	197d                	addi	s2,s2,-1
    }

    while (!USB_Is_EPx_RDY_Free(ep_idx))
230024dc:	8522                	mv	a0,s0
230024de:	3de010ef          	jal	ra,230038bc <USB_Is_EPx_RDY_Free>
230024e2:	c919                	beqz	a0,230024f8 <usb_dc_ep_write+0x54>
            return -3;
        }
    }

    // key = irq_lock();
    if (!data)
230024e4:	040a1763          	bnez	s4,23002532 <usb_dc_ep_write+0x8e>
    {
        if (!data_len)
230024e8:	020a9d63          	bnez	s5,23002522 <usb_dc_ep_write+0x7e>
        {
            /* Zero length packet */
            /* Clear NAK and enable ep */
            USB_Set_EPx_Status(USB_EP_GET_IDX(ep), USB_EP_STATUS_ACK);
230024ec:	4581                	li	a1,0
230024ee:	8522                	mv	a0,s0
230024f0:	616010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
            return 0;
230024f4:	4781                	li	a5,0
230024f6:	a821                	j	2300250e <usb_dc_ep_write+0x6a>
        if (!timeout)
230024f8:	197d                	addi	s2,s2,-1
230024fa:	fe0911e3          	bnez	s2,230024dc <usb_dc_ep_write+0x38>
            USB_DC_LOG_ERR("ep%d wait free timeout\r\n", ep);
230024fe:	23006537          	lui	a0,0x23006
23002502:	85a6                	mv	a1,s1
23002504:	a5c50513          	addi	a0,a0,-1444 # 23005a5c <led_pins+0x8>
23002508:	bebfe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            return -3;
2300250c:	57f5                	li	a5,-3
    {
        *ret_bytes = data_len;
    }

    return 0;
}
2300250e:	40f2                	lw	ra,28(sp)
23002510:	4462                	lw	s0,24(sp)
23002512:	44d2                	lw	s1,20(sp)
23002514:	4942                	lw	s2,16(sp)
23002516:	49b2                	lw	s3,12(sp)
23002518:	4a22                	lw	s4,8(sp)
2300251a:	4a92                	lw	s5,4(sp)
2300251c:	853e                	mv	a0,a5
2300251e:	6105                	addi	sp,sp,32
23002520:	8082                	ret
            USB_DC_LOG_ERR("data is null\r\n");
23002522:	23006537          	lui	a0,0x23006
23002526:	f1850513          	addi	a0,a0,-232 # 23005f18 <af_pin_table+0x36c>
2300252a:	bc9fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            return -4;
2300252e:	57f1                	li	a5,-4
23002530:	bff9                	j	2300250e <usb_dc_ep_write+0x6a>
    if (data_len > usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps)
23002532:	420247b7          	lui	a5,0x42024
23002536:	00340493          	addi	s1,s0,3
2300253a:	32078713          	addi	a4,a5,800 # 42024320 <usb_fs_device>
2300253e:	00449693          	slli	a3,s1,0x4
23002542:	9736                	add	a4,a4,a3
23002544:	01275903          	lhu	s2,18(a4)
23002548:	32078793          	addi	a5,a5,800
2300254c:	012af363          	bgeu	s5,s2,23002552 <usb_dc_ep_write+0xae>
23002550:	8956                	mv	s2,s5
        if (avail_space >= usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps)
23002552:	0492                	slli	s1,s1,0x4
23002554:	94be                	add	s1,s1,a5
        uint32_t avail_space = USB_Get_EPx_TX_FIFO_CNT(ep_idx);
23002556:	8522                	mv	a0,s0
23002558:	251010ef          	jal	ra,23003fa8 <USB_Get_EPx_TX_FIFO_CNT>
        if (avail_space >= usb_fs_device.in_ep[ep_idx].ep_cfg.ep_mps)
2300255c:	0124d783          	lhu	a5,18(s1)
23002560:	fef56be3          	bltu	a0,a5,23002556 <usb_dc_ep_write+0xb2>
    ep_tx_fifo_addr = USB_BASE + USB_EP0_TX_FIFO_WDATA_OFFSET + ep_idx * 0x10;
23002564:	4000e7b7          	lui	a5,0x4000e
23002568:	90878793          	addi	a5,a5,-1784 # 4000d908 <__ram_load_addr+0x1d0009e4>
2300256c:	00441493          	slli	s1,s0,0x4
23002570:	94be                	add	s1,s1,a5
    if((data_len == 1) && (ep_idx == 0))
23002572:	4785                	li	a5,1
23002574:	02f91363          	bne	s2,a5,2300259a <usb_dc_ep_write+0xf6>
        USB_Set_EPx_Xfer_Size(EP_ID0,1);
23002578:	4585                	li	a1,1
    if((data_len == 1) && (ep_idx == 0))
2300257a:	c01d                	beqz	s0,230025a0 <usb_dc_ep_write+0xfc>
    memcopy_to_fifo((void *)ep_tx_fifo_addr, (uint8_t *)data, data_len);
2300257c:	864a                	mv	a2,s2
2300257e:	85d2                	mv	a1,s4
23002580:	8526                	mv	a0,s1
23002582:	214030ef          	jal	ra,23005796 <memcopy_to_fifo>
    USB_Set_EPx_Status(USB_EP_GET_IDX(ep), USB_EP_STATUS_ACK);
23002586:	4581                	li	a1,0
23002588:	8522                	mv	a0,s0
2300258a:	57c010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
    return 0;
2300258e:	4781                	li	a5,0
    if (ret_bytes)
23002590:	f6098fe3          	beqz	s3,2300250e <usb_dc_ep_write+0x6a>
        *ret_bytes = data_len;
23002594:	0129a023          	sw	s2,0(s3)
23002598:	bf9d                	j	2300250e <usb_dc_ep_write+0x6a>
    else if(ep_idx == 0)
2300259a:	f06d                	bnez	s0,2300257c <usb_dc_ep_write+0xd8>
        USB_Set_EPx_Xfer_Size(EP_ID0,64);
2300259c:	04000593          	li	a1,64
230025a0:	4501                	li	a0,0
230025a2:	1aa010ef          	jal	ra,2300374c <USB_Set_EPx_Xfer_Size>
230025a6:	bfd9                	j	2300257c <usb_dc_ep_write+0xd8>
}
230025a8:	853e                	mv	a0,a5
230025aa:	8082                	ret

230025ac <usb_dc_ep_read>:
 *                          available for read should be returned.
 *
 * @return 0 on success, negative errno code on fail.
 */
int usb_dc_ep_read(struct device *dev, const uint8_t ep, uint8_t *data, uint32_t data_len, uint32_t *read_bytes)
{
230025ac:	7179                	addi	sp,sp,-48
    uint8_t ep_idx = USB_EP_GET_IDX(ep);
    uint32_t read_count;
    uint32_t ep_rx_fifo_addr;
    uint32_t timeout = 0x00FFFFFF;
    /* Check if OUT ep */
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT)
230025ae:	01859793          	slli	a5,a1,0x18
{
230025b2:	d606                	sw	ra,44(sp)
230025b4:	d422                	sw	s0,40(sp)
230025b6:	d226                	sw	s1,36(sp)
230025b8:	d04a                	sw	s2,32(sp)
230025ba:	ce4e                	sw	s3,28(sp)
230025bc:	cc52                	sw	s4,24(sp)
    if (USB_EP_GET_DIR(ep) != USB_EP_DIR_OUT)
230025be:	87e1                	srai	a5,a5,0x18
230025c0:	0207d163          	bgez	a5,230025e2 <usb_dc_ep_read+0x36>
    {
        USB_DC_LOG_ERR("Wrong endpoint direction\r\n");
230025c4:	23006537          	lui	a0,0x23006
230025c8:	ee450513          	addi	a0,a0,-284 # 23005ee4 <af_pin_table+0x338>
    }

    /* Check if ep enabled */
    if (!usb_ep_is_enabled(ep))
    {
        USB_DC_LOG_ERR("Not enabled endpoint\r\n");
230025cc:	b27fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
        return -1;
230025d0:	557d                	li	a0,-1
    {
        *read_bytes = read_count;
    }

    return 0;
}
230025d2:	50b2                	lw	ra,44(sp)
230025d4:	5422                	lw	s0,40(sp)
230025d6:	5492                	lw	s1,36(sp)
230025d8:	5902                	lw	s2,32(sp)
230025da:	49f2                	lw	s3,28(sp)
230025dc:	4a62                	lw	s4,24(sp)
230025de:	6145                	addi	sp,sp,48
230025e0:	8082                	ret
    if (!usb_ep_is_enabled(ep))
230025e2:	852e                	mv	a0,a1
230025e4:	07f5f493          	andi	s1,a1,127
230025e8:	c62e                	sw	a1,12(sp)
230025ea:	8a32                	mv	s4,a2
230025ec:	8436                	mv	s0,a3
230025ee:	89ba                	mv	s3,a4
230025f0:	8a3ff0ef          	jal	ra,23001e92 <usb_ep_is_enabled>
230025f4:	45b2                	lw	a1,12(sp)
230025f6:	e511                	bnez	a0,23002602 <usb_dc_ep_read+0x56>
        USB_DC_LOG_ERR("Not enabled endpoint\r\n");
230025f8:	23006537          	lui	a0,0x23006
230025fc:	f0050513          	addi	a0,a0,-256 # 23005f00 <af_pin_table+0x354>
23002600:	b7f1                	j	230025cc <usb_dc_ep_read+0x20>
    if(ep_idx)
23002602:	e48d                	bnez	s1,2300262c <usb_dc_ep_read+0x80>
    else if(read_bytes && data_len && (ep_idx == 0))
23002604:	02098d63          	beqz	s3,2300263e <usb_dc_ep_read+0x92>
23002608:	e83d                	bnez	s0,2300267e <usb_dc_ep_read+0xd2>
        USB_Set_EPx_Status(USB_EP_GET_IDX(ep), USB_EP_STATUS_ACK);
2300260a:	4581                	li	a1,0
2300260c:	8526                	mv	a0,s1
2300260e:	4f8010ef          	jal	ra,23003b06 <USB_Set_EPx_Status>
        return 0;
23002612:	4501                	li	a0,0
23002614:	bf7d                	j	230025d2 <usb_dc_ep_read+0x26>
            if (!timeout)
23002616:	197d                	addi	s2,s2,-1
23002618:	00091d63          	bnez	s2,23002632 <usb_dc_ep_read+0x86>
                USB_DC_LOG_ERR("ep%d wait free timeout\r\n", ep);
2300261c:	23006537          	lui	a0,0x23006
23002620:	a5c50513          	addi	a0,a0,-1444 # 23005a5c <led_pins+0x8>
23002624:	acffe0ef          	jal	ra,230010f2 <bflb_platform_printf>
                return -USB_DC_EP_TIMEOUT_ERR;
23002628:	5575                	li	a0,-3
2300262a:	b765                	j	230025d2 <usb_dc_ep_read+0x26>
2300262c:	01000937          	lui	s2,0x1000
23002630:	197d                	addi	s2,s2,-1
        while (!USB_Is_EPx_RDY_Free(ep_idx))
23002632:	8526                	mv	a0,s1
23002634:	c62e                	sw	a1,12(sp)
23002636:	286010ef          	jal	ra,230038bc <USB_Is_EPx_RDY_Free>
2300263a:	45b2                	lw	a1,12(sp)
2300263c:	dd69                	beqz	a0,23002616 <usb_dc_ep_read+0x6a>
    if (!data_len)
2300263e:	e811                	bnez	s0,23002652 <usb_dc_ep_read+0xa6>
23002640:	b7e9                	j	2300260a <usb_dc_ep_read+0x5e>
            if (!timeout)
23002642:	17fd                	addi	a5,a5,-1
23002644:	dfe1                	beqz	a5,2300261c <usb_dc_ep_read+0x70>
        while(((BL_RD_WORD(0x4000D800) & (1 << 28)) >> 28))
23002646:	8006a703          	lw	a4,-2048(a3) # ff6ff800 <__HeapLimit+0xbd6d3800>
2300264a:	00371613          	slli	a2,a4,0x3
2300264e:	fe064ae3          	bltz	a2,23002642 <usb_dc_ep_read+0x96>
    read_count = USB_Get_EPx_RX_FIFO_CNT(ep_idx);
23002652:	8526                	mv	a0,s1
23002654:	1c3010ef          	jal	ra,23004016 <USB_Get_EPx_RX_FIFO_CNT>
    read_count = MIN(read_count, data_len);
23002658:	00857363          	bgeu	a0,s0,2300265e <usb_dc_ep_read+0xb2>
2300265c:	842a                	mv	s0,a0
    fifocopy_to_mem((void *)ep_rx_fifo_addr, data, read_count);
2300265e:	4000e537          	lui	a0,0x4000e
    ep_rx_fifo_addr = (USB_BASE + USB_EP0_RX_FIFO_RDATA_OFFSET + ep_idx * 0x10);
23002662:	0492                	slli	s1,s1,0x4
    fifocopy_to_mem((void *)ep_rx_fifo_addr, data, read_count);
23002664:	90c50513          	addi	a0,a0,-1780 # 4000d90c <__ram_load_addr+0x1d0009e8>
23002668:	9526                	add	a0,a0,s1
2300266a:	8622                	mv	a2,s0
2300266c:	85d2                	mv	a1,s4
2300266e:	13c030ef          	jal	ra,230057aa <fifocopy_to_mem>
    return 0;
23002672:	4501                	li	a0,0
    if (read_bytes)
23002674:	f4098fe3          	beqz	s3,230025d2 <usb_dc_ep_read+0x26>
        *read_bytes = read_count;
23002678:	0089a023          	sw	s0,0(s3)
2300267c:	bf99                	j	230025d2 <usb_dc_ep_read+0x26>
2300267e:	010007b7          	lui	a5,0x1000
23002682:	17fd                	addi	a5,a5,-1
        while(((BL_RD_WORD(0x4000D800) & (1 << 28)) >> 28))
23002684:	4000e6b7          	lui	a3,0x4000e
23002688:	bf7d                	j	23002646 <usb_dc_ep_read+0x9a>

2300268a <usb_dc_isr>:
 * @brief
 *
 * @param device
 */
void usb_dc_isr(usb_dc_device_t *device)
{
2300268a:	1141                	addi	sp,sp,-16
2300268c:	c422                	sw	s0,8(sp)
2300268e:	c226                	sw	s1,4(sp)
23002690:	c04a                	sw	s2,0(sp)
23002692:	c606                	sw	ra,12(sp)
23002694:	842a                	mv	s0,a0
    USB_EP_ID epnum = EP_ID0;

    /* EP1_DONE -> EP2_DONE -> ...... -> EP7_DONE*/
    for (USB_INT_Type epint = USB_INT_EP1_DONE; epint <= USB_INT_EP7_DONE; epint += 2)
23002696:	44ad                	li	s1,11
23002698:	4965                	li	s2,25
    {
        if (USB_Get_IntStatus(epint))
2300269a:	8526                	mv	a0,s1
2300269c:	5d6010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230026a0:	c10d                	beqz	a0,230026c2 <usb_dc_isr+0x38>
        {
            epnum = (epint - USB_INT_EP0_OUT_CMD) >> 1;
            device->parent.callback(&device->parent,(void*)((uint32_t)USB_SET_EP_OUT(epnum)),0,USB_DC_EVENT_EP_OUT_NOTIFY);
230026a2:	545c                	lw	a5,44(s0)
            epnum = (epint - USB_INT_EP0_OUT_CMD) >> 1;
230026a4:	ff848593          	addi	a1,s1,-8
            device->parent.callback(&device->parent,(void*)((uint32_t)USB_SET_EP_OUT(epnum)),0,USB_DC_EVENT_EP_OUT_NOTIFY);
230026a8:	46b1                	li	a3,12
230026aa:	4601                	li	a2,0
230026ac:	8585                	srai	a1,a1,0x1
    for (USB_INT_Type epint = USB_INT_EP1_CMD; epint <= USB_INT_EP7_CMD; epint += 2)
    {
        if (USB_Get_IntStatus(epint))
        {
            epnum = (epint - USB_INT_EP0_OUT_CMD) >> 1;
            device->parent.callback(&device->parent,(void*)((uint32_t)USB_SET_EP_IN(epnum)),0,USB_DC_EVENT_EP_IN_NOTIFY);
230026ae:	8522                	mv	a0,s0
230026b0:	9782                	jalr	a5
            USB_Clr_IntStatus(epint);
230026b2:	8526                	mv	a0,s1
        /*************************************/
        device->parent.callback(&device->parent,NULL,0,USB_DC_EVENT_ERROR);
        USB_Clr_IntStatus(USB_INT_ERROR);
        return;
    }
}
230026b4:	4422                	lw	s0,8(sp)
230026b6:	40b2                	lw	ra,12(sp)
230026b8:	4492                	lw	s1,4(sp)
230026ba:	4902                	lw	s2,0(sp)
230026bc:	0141                	addi	sp,sp,16
        USB_Clr_IntStatus(USB_INT_ERROR);
230026be:	5dc0106f          	j	23003c9a <USB_Clr_IntStatus>
    for (USB_INT_Type epint = USB_INT_EP1_DONE; epint <= USB_INT_EP7_DONE; epint += 2)
230026c2:	0489                	addi	s1,s1,2
230026c4:	0ff4f493          	andi	s1,s1,255
230026c8:	fd2499e3          	bne	s1,s2,2300269a <usb_dc_isr+0x10>
    for (USB_INT_Type epint = USB_INT_EP1_CMD; epint <= USB_INT_EP7_CMD; epint += 2)
230026cc:	44a9                	li	s1,10
230026ce:	4961                	li	s2,24
        if (USB_Get_IntStatus(epint))
230026d0:	8526                	mv	a0,s1
230026d2:	5a0010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230026d6:	cd01                	beqz	a0,230026ee <usb_dc_isr+0x64>
            epnum = (epint - USB_INT_EP0_OUT_CMD) >> 1;
230026d8:	ff848593          	addi	a1,s1,-8
230026dc:	8585                	srai	a1,a1,0x1
            device->parent.callback(&device->parent,(void*)((uint32_t)USB_SET_EP_IN(epnum)),0,USB_DC_EVENT_EP_IN_NOTIFY);
230026de:	f805e593          	ori	a1,a1,-128
230026e2:	545c                	lw	a5,44(s0)
230026e4:	46ad                	li	a3,11
230026e6:	4601                	li	a2,0
230026e8:	0ff5f593          	andi	a1,a1,255
230026ec:	b7c9                	j	230026ae <usb_dc_isr+0x24>
    for (USB_INT_Type epint = USB_INT_EP1_CMD; epint <= USB_INT_EP7_CMD; epint += 2)
230026ee:	0489                	addi	s1,s1,2
230026f0:	0ff4f493          	andi	s1,s1,255
230026f4:	fd249ee3          	bne	s1,s2,230026d0 <usb_dc_isr+0x46>
    if (USB_Get_IntStatus(USB_INT_SOF))
230026f8:	57a010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230026fc:	c909                	beqz	a0,2300270e <usb_dc_isr+0x84>
        device->parent.callback(&device->parent,NULL,0,USB_DC_EVENT_SOF);
230026fe:	545c                	lw	a5,44(s0)
23002700:	8522                	mv	a0,s0
23002702:	4689                	li	a3,2
23002704:	4601                	li	a2,0
23002706:	4581                	li	a1,0
23002708:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_SOF);
2300270a:	4501                	li	a0,0
2300270c:	b765                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_RESET))
2300270e:	4505                	li	a0,1
23002710:	562010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
23002714:	c909                	beqz	a0,23002726 <usb_dc_isr+0x9c>
        device->parent.callback(&device->parent,NULL,0,USB_DC_EVENT_RESET);
23002716:	545c                	lw	a5,44(s0)
23002718:	8522                	mv	a0,s0
2300271a:	4685                	li	a3,1
2300271c:	4601                	li	a2,0
2300271e:	4581                	li	a1,0
23002720:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_RESET);
23002722:	4505                	li	a0,1
23002724:	bf41                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_VBUS_TGL))
23002726:	4509                	li	a0,2
23002728:	54a010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
2300272c:	c119                	beqz	a0,23002732 <usb_dc_isr+0xa8>
        USB_Clr_IntStatus(USB_INT_VBUS_TGL);
2300272e:	4509                	li	a0,2
23002730:	b751                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_EP0_SETUP_DONE))
23002732:	4515                	li	a0,5
23002734:	53e010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
23002738:	c909                	beqz	a0,2300274a <usb_dc_isr+0xc0>
        device->parent.callback(&device->parent,NULL,0,USB_DC_EVENT_SETUP_NOTIFY);
2300273a:	545c                	lw	a5,44(s0)
2300273c:	8522                	mv	a0,s0
2300273e:	46a1                	li	a3,8
23002740:	4601                	li	a2,0
23002742:	4581                	li	a1,0
23002744:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_EP0_SETUP_DONE);
23002746:	4515                	li	a0,5
23002748:	b7b5                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_EP0_IN_DONE))
2300274a:	451d                	li	a0,7
2300274c:	526010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
23002750:	c911                	beqz	a0,23002764 <usb_dc_isr+0xda>
        device->parent.callback(&device->parent,(void*)0x80,0,USB_DC_EVENT_EP0_IN_NOTIFY);
23002752:	545c                	lw	a5,44(s0)
23002754:	8522                	mv	a0,s0
23002756:	46a5                	li	a3,9
23002758:	4601                	li	a2,0
2300275a:	08000593          	li	a1,128
2300275e:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_EP0_IN_DONE);
23002760:	451d                	li	a0,7
23002762:	bf89                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_EP0_OUT_DONE))
23002764:	4525                	li	a0,9
23002766:	50c010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
2300276a:	c909                	beqz	a0,2300277c <usb_dc_isr+0xf2>
        device->parent.callback(&device->parent,(void*)0x00,0,USB_DC_EVENT_EP0_OUT_NOTIFY);
2300276c:	545c                	lw	a5,44(s0)
2300276e:	8522                	mv	a0,s0
23002770:	46a9                	li	a3,10
23002772:	4601                	li	a2,0
23002774:	4581                	li	a1,0
23002776:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_EP0_OUT_DONE);
23002778:	4525                	li	a0,9
2300277a:	bf2d                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_RESET_END))
2300277c:	456d                	li	a0,27
2300277e:	4f4010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
23002782:	c511                	beqz	a0,2300278e <usb_dc_isr+0x104>
        USB_Set_EPx_Rdy(EP_ID0);
23002784:	4501                	li	a0,0
23002786:	074010ef          	jal	ra,230037fa <USB_Set_EPx_Rdy>
        USB_Clr_IntStatus(USB_INT_RESET_END);
2300278a:	456d                	li	a0,27
2300278c:	b725                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_LPM_WAKEUP))
2300278e:	4571                	li	a0,28
23002790:	4e2010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
23002794:	c119                	beqz	a0,2300279a <usb_dc_isr+0x110>
        USB_Clr_IntStatus(USB_INT_LPM_WAKEUP);
23002796:	4571                	li	a0,28
23002798:	bf31                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_LPM_PACKET))
2300279a:	4575                	li	a0,29
2300279c:	4d6010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230027a0:	c511                	beqz	a0,230027ac <usb_dc_isr+0x122>
        if (USB_Get_IntStatus(USB_INT_LPM_WAKEUP) == 0)
230027a2:	4571                	li	a0,28
230027a4:	4ce010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
        USB_Clr_IntStatus(USB_INT_LPM_PACKET);
230027a8:	4575                	li	a0,29
230027aa:	b729                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_LOST_SOF_3_TIMES))
230027ac:	4579                	li	a0,30
230027ae:	4c4010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230027b2:	c909                	beqz	a0,230027c4 <usb_dc_isr+0x13a>
        USB_DC_LOG_ERR("Lost 3 SOFs\r\n");
230027b4:	23006537          	lui	a0,0x23006
230027b8:	f2850513          	addi	a0,a0,-216 # 23005f28 <af_pin_table+0x37c>
230027bc:	937fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
        USB_Clr_IntStatus(USB_INT_LOST_SOF_3_TIMES);
230027c0:	4579                	li	a0,30
230027c2:	bdcd                	j	230026b4 <usb_dc_isr+0x2a>
    if (USB_Get_IntStatus(USB_INT_ERROR))
230027c4:	457d                	li	a0,31
230027c6:	4ac010ef          	jal	ra,23003c72 <USB_Get_IntStatus>
230027ca:	c909                	beqz	a0,230027dc <usb_dc_isr+0x152>
        device->parent.callback(&device->parent,NULL,0,USB_DC_EVENT_ERROR);
230027cc:	545c                	lw	a5,44(s0)
230027ce:	8522                	mv	a0,s0
230027d0:	4681                	li	a3,0
230027d2:	4601                	li	a2,0
230027d4:	4581                	li	a1,0
230027d6:	9782                	jalr	a5
        USB_Clr_IntStatus(USB_INT_ERROR);
230027d8:	457d                	li	a0,31
230027da:	bde9                	j	230026b4 <usb_dc_isr+0x2a>
}
230027dc:	40b2                	lw	ra,12(sp)
230027de:	4422                	lw	s0,8(sp)
230027e0:	4492                	lw	s1,4(sp)
230027e2:	4902                	lw	s2,0(sp)
230027e4:	0141                	addi	sp,sp,16
230027e6:	8082                	ret

230027e8 <USB_IRQHandler>:
 * @brief
 *
 */
void USB_IRQHandler(void)
{
    usb_dc_isr(&usb_fs_device);
230027e8:	42024537          	lui	a0,0x42024
230027ec:	32050513          	addi	a0,a0,800 # 42024320 <usb_fs_device>
230027f0:	bd69                	j	2300268a <usb_dc_isr>

230027f2 <start_load>:
    uint32_t *pSrc, *pDest;
    uint32_t *pTable __attribute__((unused));  

    /* Copy ITCM code */
    pSrc  = &__itcm_load_addr;
    pDest = &__tcm_code_start__;
230027f2:	220147b7          	lui	a5,0x22014
    pSrc  = &__itcm_load_addr;
230027f6:	23006737          	lui	a4,0x23006
    for ( ; pDest < &__tcm_code_end__ ; ) {
230027fa:	220166b7          	lui	a3,0x22016
    pDest = &__tcm_code_start__;
230027fe:	00078793          	mv	a5,a5
    pSrc  = &__itcm_load_addr;
23002802:	7e470713          	addi	a4,a4,2020 # 230067e4 <__text_code_end__>
    for ( ; pDest < &__tcm_code_end__ ; ) {
23002806:	2e868693          	addi	a3,a3,744 # 220162e8 <__tcm_code_end__>
2300280a:	06d7e363          	bltu	a5,a3,23002870 <start_load+0x7e>
        *pDest++ = *pSrc++;
    }

    /* Copy DTCM code */
    pSrc  = &__dtcm_load_addr;
2300280e:	23009737          	lui	a4,0x23009
    pDest = &__tcm_data_start__;
23002812:	00018793          	mv	a5,gp
    pSrc  = &__dtcm_load_addr;
23002816:	acc70713          	addi	a4,a4,-1332 # 23008acc <__dtcm_load_addr>
    for( ; pDest < &__tcm_data_end__; ){
2300281a:	45818693          	addi	a3,gp,1112 # 42018458 <__tcm_data_end__>
2300281e:	06d7e063          	bltu	a5,a3,2300287e <start_load+0x8c>
        *pDest++ = *pSrc++;
    }

    /* BF Add system RAM data copy */
    pSrc  = &__system_ram_load_addr;
    pDest = &__system_ram_data_start__;
23002822:	420207b7          	lui	a5,0x42020
    pSrc  = &__system_ram_load_addr;
23002826:	23009737          	lui	a4,0x23009
    for ( ; pDest < &__system_ram_data_end__ ; ) {
2300282a:	420246b7          	lui	a3,0x42024
    pDest = &__system_ram_data_start__;
2300282e:	00078793          	mv	a5,a5
    pSrc  = &__system_ram_load_addr;
23002832:	f2470713          	addi	a4,a4,-220 # 23008f24 <__system_ram_load_addr>
    for ( ; pDest < &__system_ram_data_end__ ; ) {
23002836:	00068693          	mv	a3,a3
2300283a:	04d7e963          	bltu	a5,a3,2300288c <start_load+0x9a>
        *pDest++ = *pSrc++;
    }

    /* BF Add OCARAM data copy */
    pSrc  = &__ram_load_addr;
    pDest = &__ram_data_start__;
2300283e:	420247b7          	lui	a5,0x42024
    pSrc  = &__ram_load_addr;
23002842:	2300d737          	lui	a4,0x2300d
    for ( ; pDest < &__ram_data_end__ ; ) {
23002846:	420246b7          	lui	a3,0x42024
    pDest = &__ram_data_start__;
2300284a:	00078793          	mv	a5,a5
    pSrc  = &__ram_load_addr;
2300284e:	f2470713          	addi	a4,a4,-220 # 2300cf24 <__ram_load_addr>
    for ( ; pDest < &__ram_data_end__ ; ) {
23002852:	27068693          	addi	a3,a3,624 # 42024270 <__ram_data_end__>
23002856:	04d7e263          	bltu	a5,a3,2300289a <start_load+0xa8>
     *    __bss_start__: start of the BSS section.
     *    __bss_end__: end of the BSS section.
     *
     *  Both addresses must be aligned to 4 bytes boundary.
     */
    pDest = &__bss_start__;
2300285a:	420247b7          	lui	a5,0x42024
    for ( ; pDest < &__bss_end__ ; ) {
2300285e:	42025737          	lui	a4,0x42025
    pDest = &__bss_start__;
23002862:	27078793          	addi	a5,a5,624 # 42024270 <__ram_data_end__>
    for ( ; pDest < &__bss_end__ ; ) {
23002866:	45c70713          	addi	a4,a4,1116 # 4202545c <__bss_end__>
2300286a:	02e7ef63          	bltu	a5,a4,230028a8 <start_load+0xb6>
        *pDest++ = 0ul;
    }
#endif 
2300286e:	8082                	ret
        *pDest++ = *pSrc++;
23002870:	0711                	addi	a4,a4,4
23002872:	ffc72603          	lw	a2,-4(a4)
23002876:	0791                	addi	a5,a5,4
23002878:	fec7ae23          	sw	a2,-4(a5)
2300287c:	b779                	j	2300280a <start_load+0x18>
        *pDest++ = *pSrc++;
2300287e:	0711                	addi	a4,a4,4
23002880:	ffc72603          	lw	a2,-4(a4)
23002884:	0791                	addi	a5,a5,4
23002886:	fec7ae23          	sw	a2,-4(a5)
2300288a:	bf51                	j	2300281e <start_load+0x2c>
        *pDest++ = *pSrc++;
2300288c:	0711                	addi	a4,a4,4
2300288e:	ffc72603          	lw	a2,-4(a4)
23002892:	0791                	addi	a5,a5,4
23002894:	fec7ae23          	sw	a2,-4(a5)
23002898:	b74d                	j	2300283a <start_load+0x48>
        *pDest++ = *pSrc++;
2300289a:	0711                	addi	a4,a4,4
2300289c:	ffc72603          	lw	a2,-4(a4)
230028a0:	0791                	addi	a5,a5,4
230028a2:	fec7ae23          	sw	a2,-4(a5)
230028a6:	bf45                	j	23002856 <start_load+0x64>
        *pDest++ = 0ul;
230028a8:	0791                	addi	a5,a5,4
230028aa:	fe07ae23          	sw	zero,-4(a5)
230028ae:	bf75                	j	2300286a <start_load+0x78>

230028b0 <Interrupt_Handler_Stub>:

void __IRQ_ALIGN64 Trap_Handler_Stub(void){
    Trap_Handler();
}

void __IRQ Interrupt_Handler_Stub(void){
230028b0:	7139                	addi	sp,sp,-64
230028b2:	de06                	sw	ra,60(sp)
230028b4:	dc16                	sw	t0,56(sp)
230028b6:	da1a                	sw	t1,52(sp)
230028b8:	d81e                	sw	t2,48(sp)
230028ba:	d62a                	sw	a0,44(sp)
230028bc:	d42e                	sw	a1,40(sp)
230028be:	d232                	sw	a2,36(sp)
230028c0:	d036                	sw	a3,32(sp)
230028c2:	ce3a                	sw	a4,28(sp)
230028c4:	cc3e                	sw	a5,24(sp)
230028c6:	ca42                	sw	a6,20(sp)
230028c8:	c846                	sw	a7,16(sp)
230028ca:	c672                	sw	t3,12(sp)
230028cc:	c476                	sw	t4,8(sp)
230028ce:	c27a                	sw	t5,4(sp)
230028d0:	c07e                	sw	t6,0(sp)
    Interrupt_Handler();
230028d2:	2c59                	jal	23002b68 <Interrupt_Handler>
}
230028d4:	50f2                	lw	ra,60(sp)
230028d6:	52e2                	lw	t0,56(sp)
230028d8:	5352                	lw	t1,52(sp)
230028da:	53c2                	lw	t2,48(sp)
230028dc:	5532                	lw	a0,44(sp)
230028de:	55a2                	lw	a1,40(sp)
230028e0:	5612                	lw	a2,36(sp)
230028e2:	5682                	lw	a3,32(sp)
230028e4:	4772                	lw	a4,28(sp)
230028e6:	47e2                	lw	a5,24(sp)
230028e8:	4852                	lw	a6,20(sp)
230028ea:	48c2                	lw	a7,16(sp)
230028ec:	4e32                	lw	t3,12(sp)
230028ee:	4ea2                	lw	t4,8(sp)
230028f0:	4f12                	lw	t5,4(sp)
230028f2:	4f82                	lw	t6,0(sp)
230028f4:	6121                	addi	sp,sp,64
230028f6:	30200073          	mret
230028fa:	0000                	unimp
230028fc:	0000                	unimp
	...

23002900 <Trap_Handler_Stub>:
void __IRQ_ALIGN64 Trap_Handler_Stub(void){
23002900:	7139                	addi	sp,sp,-64
23002902:	de06                	sw	ra,60(sp)
23002904:	dc16                	sw	t0,56(sp)
23002906:	da1a                	sw	t1,52(sp)
23002908:	d81e                	sw	t2,48(sp)
2300290a:	d62a                	sw	a0,44(sp)
2300290c:	d42e                	sw	a1,40(sp)
2300290e:	d232                	sw	a2,36(sp)
23002910:	d036                	sw	a3,32(sp)
23002912:	ce3a                	sw	a4,28(sp)
23002914:	cc3e                	sw	a5,24(sp)
23002916:	ca42                	sw	a6,20(sp)
23002918:	c846                	sw	a7,16(sp)
2300291a:	c672                	sw	t3,12(sp)
2300291c:	c476                	sw	t4,8(sp)
2300291e:	c27a                	sw	t5,4(sp)
23002920:	c07e                	sw	t6,0(sp)
    Trap_Handler();
23002922:	2205                	jal	23002a42 <Trap_Handler>
}
23002924:	50f2                	lw	ra,60(sp)
23002926:	52e2                	lw	t0,56(sp)
23002928:	5352                	lw	t1,52(sp)
2300292a:	53c2                	lw	t2,48(sp)
2300292c:	5532                	lw	a0,44(sp)
2300292e:	55a2                	lw	a1,40(sp)
23002930:	5612                	lw	a2,36(sp)
23002932:	5682                	lw	a3,32(sp)
23002934:	4772                	lw	a4,28(sp)
23002936:	47e2                	lw	a5,24(sp)
23002938:	4852                	lw	a6,20(sp)
2300293a:	48c2                	lw	a7,16(sp)
2300293c:	4e32                	lw	t3,12(sp)
2300293e:	4ea2                	lw	t4,8(sp)
23002940:	4f12                	lw	t5,4(sp)
23002942:	4f82                	lw	t6,0(sp)
23002944:	6121                	addi	sp,sp,64
23002946:	30200073          	mret
	...

2300297c <clic_enable_interrupt>:

void clic_enable_interrupt (uint32_t source) {
    *(volatile uint8_t*)(CLIC_HART0_ADDR+CLIC_INTIE+source) = 1;
2300297c:	028007b7          	lui	a5,0x2800
23002980:	40078793          	addi	a5,a5,1024 # 2800400 <HeapSize+0x27ff400>
23002984:	953e                	add	a0,a0,a5
23002986:	4785                	li	a5,1
23002988:	00f50023          	sb	a5,0(a0)
}
2300298c:	8082                	ret

2300298e <clic_disable_interrupt>:

void clic_disable_interrupt ( uint32_t source){
  *(volatile uint8_t*)(CLIC_HART0_ADDR+CLIC_INTIE+source) = 0;
2300298e:	028007b7          	lui	a5,0x2800
23002992:	40078793          	addi	a5,a5,1024 # 2800400 <HeapSize+0x27ff400>
23002996:	953e                	add	a0,a0,a5
23002998:	00050023          	sb	zero,0(a0)
}
2300299c:	8082                	ret

2300299e <system_bor_init>:
  System initialization function
 *----------------------------------------------------------------------------*/

void system_bor_init(void)
{
    HBN_BOR_CFG_Type borCfg = {1/* pu_bor */, 0/* irq_bor_en */, 1/* bor_vth */, 1/* bor_sel */};
2300299e:	230067b7          	lui	a5,0x23006
230029a2:	7e07a783          	lw	a5,2016(a5) # 230067e0 <__clz_tab+0x100>
{
230029a6:	1101                	addi	sp,sp,-32
    HBN_Set_BOR_Cfg(&borCfg);
230029a8:	0068                	addi	a0,sp,12
{
230029aa:	ce06                	sw	ra,28(sp)
    HBN_BOR_CFG_Type borCfg = {1/* pu_bor */, 0/* irq_bor_en */, 1/* bor_vth */, 1/* bor_sel */};
230029ac:	c63e                	sw	a5,12(sp)
    HBN_Set_BOR_Cfg(&borCfg);
230029ae:	7e4000ef          	jal	ra,23003192 <HBN_Set_BOR_Cfg>
}
230029b2:	40f2                	lw	ra,28(sp)
230029b4:	6105                	addi	sp,sp,32
230029b6:	8082                	ret

230029b8 <SystemInit>:
    /* Disable embedded flash power up*/
    HBN_Set_Embedded_Flash_Pullup(DISABLE);
#endif

    /* disable hardware_pullup_pull_down (reg_en_hw_pu_pd = 0) */
    tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
230029b8:	4000f7b7          	lui	a5,0x4000f
230029bc:	4bd8                	lw	a4,20(a5)
    tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_REG_EN_HW_PU_PD);
230029be:	76c1                	lui	a3,0xffff0
230029c0:	16fd                	addi	a3,a3,-1
{
230029c2:	1141                	addi	sp,sp,-16
230029c4:	c606                	sw	ra,12(sp)
    tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_REG_EN_HW_PU_PD);
230029c6:	8f75                	and	a4,a4,a3
    BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
230029c8:	cbd8                	sw	a4,20(a5)

    /* disable aon_pad_ie_smt (reg_aon_pad_ie_smt = 0) */
    tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
230029ca:	4bd8                	lw	a4,20(a5)
    tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_REG_AON_PAD_IE_SMT);
230029cc:	76f9                	lui	a3,0xffffe
230029ce:	0ff68693          	addi	a3,a3,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
230029d2:	8f75                	and	a4,a4,a3
    BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
230029d4:	cbd8                	sw	a4,20(a5)

    /* GLB_Set_EM_Sel(GLB_EM_0KB); */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SEAM_MISC);
230029d6:	40000737          	lui	a4,0x40000
230029da:	5f74                	lw	a3,124(a4)
    BL_WR_REG(GLB_BASE,GLB_SEAM_MISC,tmpVal);

    /* Restore default setting*/
    /* GLB_UART_Sig_Swap_Set(UART_SIG_SWAP_NONE); */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_PARM);
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_UART_SWAP_SET,UART_SIG_SWAP_NONE);
230029dc:	f1000637          	lui	a2,0xf1000
230029e0:	167d                	addi	a2,a2,-1
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_EM_SEL,GLB_EM_0KB);
230029e2:	9ac1                	andi	a3,a3,-16
    BL_WR_REG(GLB_BASE,GLB_SEAM_MISC,tmpVal);
230029e4:	df74                	sw	a3,124(a4)
    tmpVal=BL_RD_REG(GLB_BASE,GLB_PARM);
230029e6:	08072683          	lw	a3,128(a4) # 40000080 <__ram_load_addr+0x1cff315c>
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_UART_SWAP_SET,UART_SIG_SWAP_NONE);
230029ea:	8ef1                	and	a3,a3,a2
    BL_WR_REG(GLB_BASE,GLB_PARM,tmpVal);
230029ec:	08d72023          	sw	a3,128(a4)
//    GLB_JTAG_Sig_Swap_Set(JTAG_SIG_SWAP_NONE);
//    /* update SystemCoreClock value */
//    SystemCoreClockSet(SYSTEM_CLOCK);

    /* fix 57.6M */
    if(SystemCoreClockGet()==57*6000*1000){
230029f0:	1087a683          	lw	a3,264(a5) # 4000f108 <__ram_load_addr+0x1d0021e4>
230029f4:	14628737          	lui	a4,0x14628
230029f8:	18070713          	addi	a4,a4,384 # 14628180 <HeapSize+0x14627180>
230029fc:	00e69863          	bne	a3,a4,23002a0c <SystemInit+0x54>
        SystemCoreClockSet(57.6*1000*1000)
23002a00:	036ef737          	lui	a4,0x36ef
23002a04:	80070713          	addi	a4,a4,-2048 # 36ee800 <HeapSize+0x36ed800>
23002a08:	10e7a423          	sw	a4,264(a5)
{
23002a0c:	028007b7          	lui	a5,0x2800
23002a10:	40078713          	addi	a4,a5,1024 # 2800400 <HeapSize+0x27ff400>
    }

    /* CLear all interrupt */
    p=(uint32_t *)(CLIC_HART0_ADDR+CLIC_INTIE);
    for(i=0;i<(IRQn_LAST+3)/4;i++){
23002a14:	45078793          	addi	a5,a5,1104
        p[i]=0;
23002a18:	00072023          	sw	zero,0(a4)
    for(i=0;i<(IRQn_LAST+3)/4;i++){
23002a1c:	0711                	addi	a4,a4,4
23002a1e:	fef71de3          	bne	a4,a5,23002a18 <SystemInit+0x60>
23002a22:	028007b7          	lui	a5,0x2800
    }
    p=(uint32_t *)(CLIC_HART0_ADDR+CLIC_INTIP);
    for(i=0;i<(IRQn_LAST+3)/4;i++){
23002a26:	05078713          	addi	a4,a5,80 # 2800050 <HeapSize+0x27ff050>
        p[i]=0;
23002a2a:	0007a023          	sw	zero,0(a5)
    for(i=0;i<(IRQn_LAST+3)/4;i++){
23002a2e:	0791                	addi	a5,a5,4
23002a30:	fee79de3          	bne	a5,a4,23002a2a <SystemInit+0x72>
//}
#define __SEV()                             __ASM volatile ("sev")       /* This implementation generates debug information */

__attribute__( ( always_inline ) ) __STATIC_INLINE void __enable_irq(void)
{
  __ASM volatile ("csrsi mstatus, 8");
23002a34:	30046073          	csrsi	mstatus,8

    /* global IRQ enable */
    __enable_irq();

    /* init bor for all platform */
    system_bor_init();
23002a38:	379d                	jal	2300299e <system_bor_init>
#endif
	
    /* release 64K OCARAM for appliction */
    GLB_Set_EM_Sel(GLB_EM_0KB);
    
}
23002a3a:	40b2                	lw	ra,12(sp)
    GLB_Set_EM_Sel(GLB_EM_0KB);
23002a3c:	4501                	li	a0,0
}
23002a3e:	0141                	addi	sp,sp,16
    GLB_Set_EM_Sel(GLB_EM_0KB);
23002a40:	a305                	j	23002f60 <GLB_Set_EM_Sel>

23002a42 <Trap_Handler>:
    unsigned long cause;
    unsigned long epc;
    unsigned long tval;
    uint8_t isecall=0;

    MSG("Trap_Handler\r\n");
23002a42:	23006537          	lui	a0,0x23006
void Trap_Handler(void){
23002a46:	1141                	addi	sp,sp,-16
    MSG("Trap_Handler\r\n");
23002a48:	ff050513          	addi	a0,a0,-16 # 23005ff0 <af_pin_table+0x444>
void Trap_Handler(void){
23002a4c:	c606                	sw	ra,12(sp)
23002a4e:	c422                	sw	s0,8(sp)
23002a50:	c226                	sw	s1,4(sp)
    MSG("Trap_Handler\r\n");
23002a52:	ea0fe0ef          	jal	ra,230010f2 <bflb_platform_printf>

    cause = read_csr(mcause);
23002a56:	342024f3          	csrr	s1,mcause
    MSG("mcause=%08x\r\n",(uint32_t)cause);
23002a5a:	23006537          	lui	a0,0x23006
23002a5e:	85a6                	mv	a1,s1
23002a60:	00050513          	mv	a0,a0
23002a64:	e8efe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    epc=read_csr(mepc);
23002a68:	34102473          	csrr	s0,mepc
    MSG("mepc:%08x\r\n",(uint32_t)epc);
23002a6c:	23006537          	lui	a0,0x23006
23002a70:	85a2                	mv	a1,s0
23002a72:	01050513          	addi	a0,a0,16 # 23006010 <af_pin_table+0x464>
23002a76:	e7cfe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    tval=read_csr(mtval);
23002a7a:	343025f3          	csrr	a1,mtval
    MSG("mtval:%08x\r\n",(uint32_t)tval);
23002a7e:	23006537          	lui	a0,0x23006
23002a82:	01c50513          	addi	a0,a0,28 # 2300601c <af_pin_table+0x470>
23002a86:	e6cfe0ef          	jal	ra,230010f2 <bflb_platform_printf>

    cause=(cause&0x3ff);
23002a8a:	3ff4f593          	andi	a1,s1,1023
    switch(cause){
23002a8e:	fff58793          	addi	a5,a1,-1
23002a92:	4729                	li	a4,10
23002a94:	0af76363          	bltu	a4,a5,23002b3a <Trap_Handler+0xf8>
23002a98:	23006737          	lui	a4,0x23006
23002a9c:	078a                	slli	a5,a5,0x2
23002a9e:	f3870713          	addi	a4,a4,-200 # 23005f38 <af_pin_table+0x38c>
23002aa2:	97ba                	add	a5,a5,a4
23002aa4:	439c                	lw	a5,0(a5)
23002aa6:	8782                	jr	a5
        case 1:
            MSG("Instruction access fault\r\n");
23002aa8:	23006537          	lui	a0,0x23006
23002aac:	02c50513          	addi	a0,a0,44 # 2300602c <af_pin_table+0x480>
23002ab0:	e42fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            write_csr(mepc,epc);
            break;
    }

    if(!isecall){
        while(1);
23002ab4:	a001                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Illegal instruction\r\n");
23002ab6:	23006537          	lui	a0,0x23006
23002aba:	04850513          	addi	a0,a0,72 # 23006048 <af_pin_table+0x49c>
23002abe:	e34fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002ac2:	bfcd                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Breakpoint\r\n");
23002ac4:	23006537          	lui	a0,0x23006
23002ac8:	06050513          	addi	a0,a0,96 # 23006060 <af_pin_table+0x4b4>
23002acc:	e26fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002ad0:	b7d5                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Load address misaligned\r\n");
23002ad2:	23006537          	lui	a0,0x23006
23002ad6:	07050513          	addi	a0,a0,112 # 23006070 <af_pin_table+0x4c4>
23002ada:	e18fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002ade:	bfd9                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Load access fault\r\n");
23002ae0:	23006537          	lui	a0,0x23006
23002ae4:	08c50513          	addi	a0,a0,140 # 2300608c <af_pin_table+0x4e0>
23002ae8:	e0afe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002aec:	b7e1                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Store/AMO address misaligned\r\n");
23002aee:	23006537          	lui	a0,0x23006
23002af2:	0a050513          	addi	a0,a0,160 # 230060a0 <af_pin_table+0x4f4>
23002af6:	dfcfe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002afa:	bf6d                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Store/AMO access fault\r\n");
23002afc:	23006537          	lui	a0,0x23006
23002b00:	0c050513          	addi	a0,a0,192 # 230060c0 <af_pin_table+0x514>
23002b04:	deefe0ef          	jal	ra,230010f2 <bflb_platform_printf>
    if(!isecall){
23002b08:	b775                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Environment call from U-mode\r\n");
23002b0a:	23006537          	lui	a0,0x23006
23002b0e:	0dc50513          	addi	a0,a0,220 # 230060dc <af_pin_table+0x530>
23002b12:	de0fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            epc+=4;
23002b16:	0411                	addi	s0,s0,4
            write_csr(mepc,epc);
23002b18:	34141073          	csrw	mepc,s0
    if(!isecall){
23002b1c:	bf61                	j	23002ab4 <Trap_Handler+0x72>
            MSG("Environment call from M-mode\r\n");
23002b1e:	23006537          	lui	a0,0x23006
23002b22:	0fc50513          	addi	a0,a0,252 # 230060fc <af_pin_table+0x550>
23002b26:	dccfe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            epc+=4;
23002b2a:	0411                	addi	s0,s0,4
            write_csr(mepc,epc);
23002b2c:	34141073          	csrw	mepc,s0
    }
}
23002b30:	40b2                	lw	ra,12(sp)
23002b32:	4422                	lw	s0,8(sp)
23002b34:	4492                	lw	s1,4(sp)
23002b36:	0141                	addi	sp,sp,16
23002b38:	8082                	ret
            MSG("Cause num=%d\r\n",(uint32_t)cause);
23002b3a:	23006537          	lui	a0,0x23006
23002b3e:	11c50513          	addi	a0,a0,284 # 2300611c <af_pin_table+0x570>
23002b42:	db0fe0ef          	jal	ra,230010f2 <bflb_platform_printf>
            epc+=4;
23002b46:	0411                	addi	s0,s0,4
            write_csr(mepc,epc);
23002b48:	34141073          	csrw	mepc,s0
    if(!isecall){
23002b4c:	b7a5                	j	23002ab4 <Trap_Handler+0x72>

23002b4e <Interrupt_Handler_Register>:

void Interrupt_Handler_Register(IRQn_Type irq,pFunc interruptFun)
{
    if(irq<IRQn_LAST){
23002b4e:	04f00793          	li	a5,79
23002b52:	00a7ea63          	bltu	a5,a0,23002b66 <Interrupt_Handler_Register+0x18>
        __Interrupt_Handlers[irq]=interruptFun;
23002b56:	00251793          	slli	a5,a0,0x2
23002b5a:	42024537          	lui	a0,0x42024
23002b5e:	47050513          	addi	a0,a0,1136 # 42024470 <__Interrupt_Handlers>
23002b62:	953e                	add	a0,a0,a5
23002b64:	c10c                	sw	a1,0(a0)
    }
}
23002b66:	8082                	ret

23002b68 <Interrupt_Handler>:

void Interrupt_Handler(void)
{
23002b68:	1101                	addi	sp,sp,-32
    pFunc interruptFun;
    uint32_t num=0;
    volatile uint32_t ulMEPC = 0UL, ulMCAUSE = 0UL;
23002b6a:	c402                	sw	zero,8(sp)
{
23002b6c:	ce06                	sw	ra,28(sp)
23002b6e:	cc22                	sw	s0,24(sp)
23002b70:	ca26                	sw	s1,20(sp)
    volatile uint32_t ulMEPC = 0UL, ulMCAUSE = 0UL;
23002b72:	c602                	sw	zero,12(sp)

    /* Store a few register values that might be useful when determining why this
    function was called. */
    __asm volatile( "csrr %0, mepc" : "=r"( ulMEPC ) );
23002b74:	341027f3          	csrr	a5,mepc
23002b78:	c43e                	sw	a5,8(sp)
    __asm volatile( "csrr %0, mcause" : "=r"( ulMCAUSE ) );
23002b7a:	342027f3          	csrr	a5,mcause
23002b7e:	c63e                	sw	a5,12(sp)
    
    if((ulMCAUSE&0x80000000)==0){
23002b80:	47b2                	lw	a5,12(sp)
23002b82:	0007cc63          	bltz	a5,23002b9a <Interrupt_Handler+0x32>
            }
        }else{
            MSG("Unexpected interrupt num:%d\r\n",(unsigned int)num);
        }
    }
}
23002b86:	4462                	lw	s0,24(sp)
23002b88:	40f2                	lw	ra,28(sp)
23002b8a:	44d2                	lw	s1,20(sp)
        MSG("Exception should not be here\r\n");
23002b8c:	23006537          	lui	a0,0x23006
23002b90:	f6450513          	addi	a0,a0,-156 # 23005f64 <af_pin_table+0x3b8>
}
23002b94:	6105                	addi	sp,sp,32
        MSG("Exception should not be here\r\n");
23002b96:	d5cfe06f          	j	230010f2 <bflb_platform_printf>
        num=ulMCAUSE&0x3FF;
23002b9a:	44b2                	lw	s1,12(sp)
        if(num<IRQn_LAST){
23002b9c:	04f00793          	li	a5,79
        num=ulMCAUSE&0x3FF;
23002ba0:	3ff4f413          	andi	s0,s1,1023
        if(num<IRQn_LAST){
23002ba4:	0487e563          	bltu	a5,s0,23002bee <Interrupt_Handler+0x86>
            interruptFun=__Interrupt_Handlers[num];
23002ba8:	42024737          	lui	a4,0x42024
23002bac:	00241793          	slli	a5,s0,0x2
23002bb0:	47070713          	addi	a4,a4,1136 # 42024470 <__Interrupt_Handlers>
23002bb4:	97ba                	add	a5,a5,a4
23002bb6:	0007a303          	lw	t1,0(a5)
            if(NULL!=interruptFun){
23002bba:	00030763          	beqz	t1,23002bc8 <Interrupt_Handler+0x60>
}
23002bbe:	4462                	lw	s0,24(sp)
23002bc0:	40f2                	lw	ra,28(sp)
23002bc2:	44d2                	lw	s1,20(sp)
23002bc4:	6105                	addi	sp,sp,32
                interruptFun();
23002bc6:	8302                	jr	t1
                MSG("Interrupt num:%d IRQHandler not installed\r\n",(unsigned int)num);
23002bc8:	23006537          	lui	a0,0x23006
23002bcc:	85a2                	mv	a1,s0
23002bce:	f8450513          	addi	a0,a0,-124 # 23005f84 <af_pin_table+0x3d8>
                if(num>=IRQ_NUM_BASE){
23002bd2:	3f04f493          	andi	s1,s1,1008
                MSG("Interrupt num:%d IRQHandler not installed\r\n",(unsigned int)num);
23002bd6:	d1cfe0ef          	jal	ra,230010f2 <bflb_platform_printf>
                if(num>=IRQ_NUM_BASE){
23002bda:	c889                	beqz	s1,23002bec <Interrupt_Handler+0x84>
                    MSG("Peripheral Interrupt num:%d \r\n",(unsigned int)num-IRQ_NUM_BASE);
23002bdc:	23006537          	lui	a0,0x23006
23002be0:	ff040593          	addi	a1,s0,-16
23002be4:	fb050513          	addi	a0,a0,-80 # 23005fb0 <af_pin_table+0x404>
23002be8:	d0afe0ef          	jal	ra,230010f2 <bflb_platform_printf>
                while(1);
23002bec:	a001                	j	23002bec <Interrupt_Handler+0x84>
            MSG("Unexpected interrupt num:%d\r\n",(unsigned int)num);
23002bee:	85a2                	mv	a1,s0
}
23002bf0:	4462                	lw	s0,24(sp)
23002bf2:	40f2                	lw	ra,28(sp)
23002bf4:	44d2                	lw	s1,20(sp)
            MSG("Unexpected interrupt num:%d\r\n",(unsigned int)num);
23002bf6:	23006537          	lui	a0,0x23006
23002bfa:	fd050513          	addi	a0,a0,-48 # 23005fd0 <af_pin_table+0x424>
}
23002bfe:	6105                	addi	sp,sp,32
            MSG("Unexpected interrupt num:%d\r\n",(unsigned int)num);
23002c00:	cf2fe06f          	j	230010f2 <bflb_platform_printf>

23002c04 <DMA_ALL_IRQHandler>:
 * @return None
 *
*******************************************************************************/
#ifndef BFLB_USE_HAL_DRIVER
void DMA_ALL_IRQHandler(void)
{
23002c04:	1101                	addi	sp,sp,-32
23002c06:	c84a                	sw	s2,16(sp)
            intClr = BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCCLEAR);
            intClr |= (1 << ch);
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_INTTCCLEAR, intClr);
            BL_WR_REG(DMAChs, DMA_INTTCCLEAR, tmpVal);

            if(dmaIntCbfArra[ch][DMA_INT_TCOMPLETED] != NULL) {
23002c08:	42024937          	lui	s2,0x42024
{
23002c0c:	cc22                	sw	s0,24(sp)
23002c0e:	ca26                	sw	s1,20(sp)
23002c10:	c64e                	sw	s3,12(sp)
23002c12:	c452                	sw	s4,8(sp)
23002c14:	ce06                	sw	ra,28(sp)
23002c16:	4401                	li	s0,0
        tmpVal = BL_RD_REG(DMAChs, DMA_INTTCSTATUS);
23002c18:	4000c4b7          	lui	s1,0x4000c
        if((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCSTATUS) & (1 << ch)) != 0) {
23002c1c:	4a05                	li	s4,1
            if(dmaIntCbfArra[ch][DMA_INT_TCOMPLETED] != NULL) {
23002c1e:	5b090913          	addi	s2,s2,1456 # 420245b0 <dmaIntCbfArra>
    for(ch=0;ch<DMA_CH_MAX;ch++){
23002c22:	49a1                	li	s3,8
        tmpVal = BL_RD_REG(DMAChs, DMA_INTTCSTATUS);
23002c24:	40d8                	lw	a4,4(s1)
        if((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTTCSTATUS) & (1 << ch)) != 0) {
23002c26:	008a17b3          	sll	a5,s4,s0
23002c2a:	8f7d                	and	a4,a4,a5
23002c2c:	cb11                	beqz	a4,23002c40 <DMA_ALL_IRQHandler+0x3c>
            tmpVal = BL_RD_REG(DMAChs, DMA_INTTCCLEAR);
23002c2e:	4498                	lw	a4,8(s1)
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_INTTCCLEAR, intClr);
23002c30:	8fd9                	or	a5,a5,a4
            BL_WR_REG(DMAChs, DMA_INTTCCLEAR, tmpVal);
23002c32:	c49c                	sw	a5,8(s1)
            if(dmaIntCbfArra[ch][DMA_INT_TCOMPLETED] != NULL) {
23002c34:	00341793          	slli	a5,s0,0x3
23002c38:	97ca                	add	a5,a5,s2
23002c3a:	439c                	lw	a5,0(a5)
23002c3c:	c391                	beqz	a5,23002c40 <DMA_ALL_IRQHandler+0x3c>
                /* Call the callback function */
                dmaIntCbfArra[ch][DMA_INT_TCOMPLETED]();
23002c3e:	9782                	jalr	a5
    for(ch=0;ch<DMA_CH_MAX;ch++){
23002c40:	0405                	addi	s0,s0,1
23002c42:	ff3411e3          	bne	s0,s3,23002c24 <DMA_ALL_IRQHandler+0x20>
23002c46:	42024437          	lui	s0,0x42024
23002c4a:	5b040413          	addi	s0,s0,1456 # 420245b0 <dmaIntCbfArra>
23002c4e:	4481                	li	s1,0
            }
        }
    }

    for(ch=0;ch<DMA_CH_MAX;ch++){
        tmpVal = BL_RD_REG(DMAChs, DMA_INTERRORSTATUS);
23002c50:	4000c937          	lui	s2,0x4000c
        if((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRORSTATUS) & (1 << ch)) != 0) {
23002c54:	4a05                	li	s4,1
    for(ch=0;ch<DMA_CH_MAX;ch++){
23002c56:	49a1                	li	s3,8
        tmpVal = BL_RD_REG(DMAChs, DMA_INTERRORSTATUS);
23002c58:	00c92703          	lw	a4,12(s2) # 4000c00c <__ram_load_addr+0x1cfff0e8>
        if((BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRORSTATUS) & (1 << ch)) != 0) {
23002c5c:	009a17b3          	sll	a5,s4,s1
23002c60:	8f7d                	and	a4,a4,a5
23002c62:	cb09                	beqz	a4,23002c74 <DMA_ALL_IRQHandler+0x70>
            /*Clear interrupt */
            tmpVal = BL_RD_REG(DMAChs, DMA_INTERRCLR);
23002c64:	01092703          	lw	a4,16(s2)
            intClr = BL_GET_REG_BITS_VAL(tmpVal, DMA_INTERRCLR);
            intClr |= (1 << ch);
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_INTERRCLR, intClr);
23002c68:	8fd9                	or	a5,a5,a4
            BL_WR_REG(DMAChs, DMA_INTERRCLR, tmpVal);
23002c6a:	00f92823          	sw	a5,16(s2)

            if(dmaIntCbfArra[ch][DMA_INT_ERR] != NULL) {
23002c6e:	405c                	lw	a5,4(s0)
23002c70:	c391                	beqz	a5,23002c74 <DMA_ALL_IRQHandler+0x70>
                /* Call the callback function */
                dmaIntCbfArra[ch][DMA_INT_ERR]();
23002c72:	9782                	jalr	a5
    for(ch=0;ch<DMA_CH_MAX;ch++){
23002c74:	0485                	addi	s1,s1,1
23002c76:	0421                	addi	s0,s0,8
23002c78:	ff3490e3          	bne	s1,s3,23002c58 <DMA_ALL_IRQHandler+0x54>
            }
        }
    }
}
23002c7c:	40f2                	lw	ra,28(sp)
23002c7e:	4462                	lw	s0,24(sp)
23002c80:	44d2                	lw	s1,20(sp)
23002c82:	4942                	lw	s2,16(sp)
23002c84:	49b2                	lw	s3,12(sp)
23002c86:	4a22                	lw	s4,8(sp)
23002c88:	6105                	addi	sp,sp,32
23002c8a:	8082                	ret

23002c8c <DMA_Enable>:
{
    uint32_t tmpVal;
    /* Get DMA register */
    uint32_t DMAChs = DMA_BASE;

    tmpVal = BL_RD_REG(DMAChs, DMA_TOP_CONFIG);
23002c8c:	4000c737          	lui	a4,0x4000c
23002c90:	5b1c                	lw	a5,48(a4)
    tmpVal = BL_SET_REG_BIT(tmpVal, DMA_E);
    BL_WR_REG(DMAChs, DMA_TOP_CONFIG, tmpVal);
#ifndef BFLB_USE_HAL_DRIVER
    Interrupt_Handler_Register(DMA_ALL_IRQn,DMA_ALL_IRQHandler);
23002c92:	230035b7          	lui	a1,0x23003
23002c96:	c0458593          	addi	a1,a1,-1020 # 23002c04 <DMA_ALL_IRQHandler>
    tmpVal = BL_SET_REG_BIT(tmpVal, DMA_E);
23002c9a:	0017e793          	ori	a5,a5,1
    BL_WR_REG(DMAChs, DMA_TOP_CONFIG, tmpVal);
23002c9e:	db1c                	sw	a5,48(a4)
    Interrupt_Handler_Register(DMA_ALL_IRQn,DMA_ALL_IRQHandler);
23002ca0:	457d                	li	a0,31
23002ca2:	b575                	j	23002b4e <Interrupt_Handler_Register>

23002ca4 <DMA_Disable>:
{
    uint32_t tmpVal;
    /* Get DMA register */
    uint32_t DMAChs = DMA_BASE;

    tmpVal = BL_RD_REG(DMAChs, DMA_TOP_CONFIG);
23002ca4:	4000c737          	lui	a4,0x4000c
23002ca8:	5b1c                	lw	a5,48(a4)
    tmpVal = BL_CLR_REG_BIT(tmpVal, DMA_E);
23002caa:	9bf9                	andi	a5,a5,-2
    BL_WR_REG(DMAChs, DMA_TOP_CONFIG, tmpVal);
23002cac:	db1c                	sw	a5,48(a4)
}
23002cae:	8082                	ret

23002cb0 <DMA_Channel_Is_Busy>:
    uint32_t DMAChs = DMA_Get_Channel(ch);

    /* Check the parameters */
    CHECK_PARAM(IS_DMA_CHAN_TYPE(ch));

    return BL_IS_REG_BIT_SET(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_E) == 1 ? SET:RESET;
23002cb0:	4000c7b7          	lui	a5,0x4000c
23002cb4:	11078793          	addi	a5,a5,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002cb8:	0522                	slli	a0,a0,0x8
    return BL_IS_REG_BIT_SET(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_E) == 1 ? SET:RESET;
23002cba:	953e                	add	a0,a0,a5
23002cbc:	4108                	lw	a0,0(a0)
}
23002cbe:	8905                	andi	a0,a0,1
23002cc0:	8082                	ret

23002cc2 <DMA_Channel_Enable>:
    uint32_t DMAChs = DMA_Get_Channel(ch);

    /* Check the parameters */
    CHECK_PARAM(IS_DMA_CHAN_TYPE(ch));

    tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002cc2:	4000c7b7          	lui	a5,0x4000c
23002cc6:	11078793          	addi	a5,a5,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002cca:	0522                	slli	a0,a0,0x8
    tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002ccc:	953e                	add	a0,a0,a5
23002cce:	411c                	lw	a5,0(a0)
    tmpVal = BL_SET_REG_BIT(tmpVal, DMA_E);
23002cd0:	0017e793          	ori	a5,a5,1
    BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
23002cd4:	c11c                	sw	a5,0(a0)
}
23002cd6:	8082                	ret

23002cd8 <DMA_Channel_Disable>:
    uint32_t DMAChs = DMA_Get_Channel(ch);

    /* Check the parameters */
    CHECK_PARAM(IS_DMA_CHAN_TYPE(ch));

    tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002cd8:	4000c7b7          	lui	a5,0x4000c
23002cdc:	11078793          	addi	a5,a5,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002ce0:	0522                	slli	a0,a0,0x8
    tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002ce2:	953e                	add	a0,a0,a5
23002ce4:	411c                	lw	a5,0(a0)
    tmpVal = BL_CLR_REG_BIT(tmpVal, DMA_E);
23002ce6:	9bf9                	andi	a5,a5,-2
    BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
23002ce8:	c11c                	sw	a5,0(a0)
}
23002cea:	8082                	ret

23002cec <DMA_LLI_Init>:
 *
 * @return None
 *
*******************************************************************************/
void DMA_LLI_Init(uint8_t ch,DMA_LLI_Cfg_Type *lliCfg)
{
23002cec:	1141                	addi	sp,sp,-16
23002cee:	c422                	sw	s0,8(sp)
23002cf0:	c226                	sw	s1,4(sp)
23002cf2:	842a                	mv	s0,a0
23002cf4:	84ae                	mv	s1,a1
    CHECK_PARAM(IS_DMA_TRANS_DIR_TYPE(lliCfg->dir));
    CHECK_PARAM(IS_DMA_PERIPH_REQ_TYPE(lliCfg->dstPeriph));
    CHECK_PARAM(IS_DMA_PERIPH_REQ_TYPE(lliCfg->srcPeriph));

    /* Disable clock gate */
    GLB_AHB_Slave1_Clock_Gate(DISABLE,BL_AHB_SLAVE1_DMA);
23002cf6:	4501                	li	a0,0
23002cf8:	45b1                	li	a1,12
{
23002cfa:	c606                	sw	ra,12(sp)
    GLB_AHB_Slave1_Clock_Gate(DISABLE,BL_AHB_SLAVE1_DMA);
23002cfc:	2ae1                	jal	23002ed4 <GLB_AHB_Slave1_Clock_Gate>
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002cfe:	0422                	slli	s0,s0,0x8

    tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002d00:	4000c537          	lui	a0,0x4000c
23002d04:	11050513          	addi	a0,a0,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
23002d08:	9522                	add	a0,a0,s0
23002d0a:	411c                	lw	a5,0(a0)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_FLOWCNTRL, lliCfg->dir);
23002d0c:	7771                	lui	a4,0xffffc
23002d0e:	7ff70713          	addi	a4,a4,2047 # ffffc7ff <__HeapLimit+0xbdfd07ff>
23002d12:	8f7d                	and	a4,a4,a5
23002d14:	0004c783          	lbu	a5,0(s1) # 4000c000 <__ram_load_addr+0x1cfff0dc>
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_DSTPERIPHERAL, lliCfg->dstPeriph);
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_SRCPERIPHERAL, lliCfg->srcPeriph);
    BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
}
23002d18:	40b2                	lw	ra,12(sp)
23002d1a:	4422                	lw	s0,8(sp)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_FLOWCNTRL, lliCfg->dir);
23002d1c:	07ae                	slli	a5,a5,0xb
23002d1e:	8fd9                	or	a5,a5,a4
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_DSTPERIPHERAL, lliCfg->dstPeriph);
23002d20:	0024c703          	lbu	a4,2(s1)
23002d24:	8017f793          	andi	a5,a5,-2047
23002d28:	071a                	slli	a4,a4,0x6
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_SRCPERIPHERAL, lliCfg->srcPeriph);
23002d2a:	8fd9                	or	a5,a5,a4
23002d2c:	0014c703          	lbu	a4,1(s1)
}
23002d30:	4492                	lw	s1,4(sp)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal, DMA_SRCPERIPHERAL, lliCfg->srcPeriph);
23002d32:	0706                	slli	a4,a4,0x1
23002d34:	8fd9                	or	a5,a5,a4
    BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
23002d36:	c11c                	sw	a5,0(a0)
}
23002d38:	0141                	addi	sp,sp,16
23002d3a:	8082                	ret

23002d3c <DMA_LLI_Update>:
    /* Check the parameters */
    CHECK_PARAM(IS_DMA_CHAN_TYPE(ch));

    /* Config channel config */
    //BL_WR_REG(DMAChs, DMA_LLI, LLI);
    BL702_MemCpy4((uint32_t*)DMAChs,(uint32_t*)LLI,4);
23002d3c:	4000c7b7          	lui	a5,0x4000c
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002d40:	0522                	slli	a0,a0,0x8
    BL702_MemCpy4((uint32_t*)DMAChs,(uint32_t*)LLI,4);
23002d42:	10078793          	addi	a5,a5,256 # 4000c100 <__ram_load_addr+0x1cfff1dc>
23002d46:	4611                	li	a2,4
23002d48:	953e                	add	a0,a0,a5
23002d4a:	ff013317          	auipc	t1,0xff013
23002d4e:	a5030067          	jr	-1456(t1) # 2201579a <arch_memcpy4>

23002d52 <DMA_IntMask>:

    /* Check the parameters */
    CHECK_PARAM(IS_DMA_CHAN_TYPE(ch));
    CHECK_PARAM(IS_DMA_INT_TYPE(intType));

    switch(intType)
23002d52:	4785                	li	a5,1
    uint32_t DMAChs = DMA_Get_Channel(ch);
23002d54:	0522                	slli	a0,a0,0x8
    switch(intType)
23002d56:	02f58963          	beq	a1,a5,23002d88 <DMA_IntMask+0x36>
23002d5a:	c589                	beqz	a1,23002d64 <DMA_IntMask+0x12>
23002d5c:	4789                	li	a5,2
23002d5e:	04f58463          	beq	a1,a5,23002da6 <DMA_IntMask+0x54>
23002d62:	8082                	ret
    {
        case DMA_INT_TCOMPLETED:
            if(intMask == UNMASK)
23002d64:	4000c737          	lui	a4,0x4000c
23002d68:	11070793          	addi	a5,a4,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
23002d6c:	10c70713          	addi	a4,a4,268
23002d70:	97aa                	add	a5,a5,a0
23002d72:	953a                	add	a0,a0,a4
            {
                /* UNMASK(Enable) this interrupt */
                tmpVal = BL_CLR_REG_BIT(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_ITC);
23002d74:	4398                	lw	a4,0(a5)
23002d76:	76e1                	lui	a3,0xffff8
            if(intMask == UNMASK)
23002d78:	c231                	beqz	a2,23002dbc <DMA_IntMask+0x6a>
                BL_WR_REG(DMAChs, DMA_CONTROL, tmpVal);
            }
            else
            {
                /* MASK(Disable) this interrupt */
                tmpVal = BL_SET_REG_BIT(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_ITC);
23002d7a:	66a1                	lui	a3,0x8
            else
            {
                /* MASK(Disable) this interrupt */
                tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_ITC);
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_IE);
23002d7c:	8f55                	or	a4,a4,a3
                BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
23002d7e:	c398                	sw	a4,0(a5)
                tmpVal = BL_RD_REG(DMAChs, DMA_CONTROL);
23002d80:	411c                	lw	a5,0(a0)
                tmpVal = BL_CLR_REG_BIT(tmpVal, DMA_I);
23002d82:	0786                	slli	a5,a5,0x1
23002d84:	8385                	srli	a5,a5,0x1
23002d86:	a819                	j	23002d9c <DMA_IntMask+0x4a>
            if(intMask == UNMASK)
23002d88:	4000c7b7          	lui	a5,0x4000c
23002d8c:	11078793          	addi	a5,a5,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
23002d90:	953e                	add	a0,a0,a5
                tmpVal = BL_CLR_REG_BIT(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_IE);
23002d92:	411c                	lw	a5,0(a0)
            if(intMask == UNMASK)
23002d94:	e611                	bnez	a2,23002da0 <DMA_IntMask+0x4e>
                tmpVal = BL_CLR_REG_BIT(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_IE);
23002d96:	7771                	lui	a4,0xffffc
23002d98:	177d                	addi	a4,a4,-1
23002d9a:	8ff9                	and	a5,a5,a4
                BL_WR_REG(DMAChs, DMA_CONTROL, tmpVal);
23002d9c:	c11c                	sw	a5,0(a0)
            break;

        default:
            break;
    }
}
23002d9e:	8082                	ret
                tmpVal = BL_SET_REG_BIT(BL_RD_REG(DMAChs, DMA_CONFIG), DMA_IE);
23002da0:	6711                	lui	a4,0x4
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_I);
23002da2:	8fd9                	or	a5,a5,a4
                BL_WR_REG(DMAChs, DMA_CONTROL, tmpVal);
23002da4:	bfe5                	j	23002d9c <DMA_IntMask+0x4a>
            if(intMask == UNMASK)
23002da6:	4000c737          	lui	a4,0x4000c
23002daa:	11070793          	addi	a5,a4,272 # 4000c110 <__ram_load_addr+0x1cfff1ec>
23002dae:	10c70713          	addi	a4,a4,268
23002db2:	97aa                	add	a5,a5,a0
23002db4:	953a                	add	a0,a0,a4
                tmpVal = BL_RD_REG(DMAChs, DMA_CONFIG);
23002db6:	4398                	lw	a4,0(a5)
            if(intMask == UNMASK)
23002db8:	ea09                	bnez	a2,23002dca <DMA_IntMask+0x78>
                tmpVal = BL_CLR_REG_BIT(tmpVal, DMA_IE);
23002dba:	76d1                	lui	a3,0xffff4
23002dbc:	16fd                	addi	a3,a3,-1
23002dbe:	8f75                	and	a4,a4,a3
                BL_WR_REG(DMAChs, DMA_CONFIG, tmpVal);
23002dc0:	c398                	sw	a4,0(a5)
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_I);
23002dc2:	80000737          	lui	a4,0x80000
                tmpVal = BL_RD_REG(DMAChs, DMA_CONTROL);
23002dc6:	411c                	lw	a5,0(a0)
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_I);
23002dc8:	bfe9                	j	23002da2 <DMA_IntMask+0x50>
                tmpVal = BL_SET_REG_BIT(tmpVal, DMA_IE);
23002dca:	66b1                	lui	a3,0xc
23002dcc:	bf45                	j	23002d7c <DMA_IntMask+0x2a>

23002dce <EF_Ctrl_Get_Byte_Zero_Cnt>:
*******************************************************************************/
static uint32_t EF_Ctrl_Get_Byte_Zero_Cnt(uint8_t val)
{
    uint32_t cnt=0;
    uint32_t i=0;
    for(i=0;i<8;i++){
23002dce:	4781                	li	a5,0
    uint32_t cnt=0;
23002dd0:	4701                	li	a4,0
    for(i=0;i<8;i++){
23002dd2:	4621                	li	a2,8
        if((val&(1<<i))==0){
23002dd4:	40f556b3          	sra	a3,a0,a5
23002dd8:	8a85                	andi	a3,a3,1
23002dda:	e291                	bnez	a3,23002dde <EF_Ctrl_Get_Byte_Zero_Cnt+0x10>
            cnt+=1;
23002ddc:	0705                	addi	a4,a4,1
    for(i=0;i<8;i++){
23002dde:	0785                	addi	a5,a5,1
23002de0:	fec79ae3          	bne	a5,a2,23002dd4 <EF_Ctrl_Get_Byte_Zero_Cnt+0x6>
        }
    }
    return cnt;
}
23002de4:	853a                	mv	a0,a4
23002de6:	8082                	ret

23002de8 <EF_Ctrl_Read_MAC_Address>:
 *
 * @return SUCCESS or ERROR
 *
*******************************************************************************/
BL_Err_Type EF_Ctrl_Read_MAC_Address(uint8_t mac[8])
{
23002de8:	1101                	addi	sp,sp,-32
23002dea:	cc22                	sw	s0,24(sp)
23002dec:	ca26                	sw	s1,20(sp)
23002dee:	842a                	mv	s0,a0
23002df0:	c84a                	sw	s2,16(sp)
23002df2:	c64e                	sw	s3,12(sp)
23002df4:	c452                	sw	s4,8(sp)
23002df6:	ce06                	sw	ra,28(sp)
    uint32_t tmpVal;
    uint32_t i=0;
    uint32_t cnt=0;

    /* Trigger read data from efuse */
    EF_CTRL_LOAD_BEFORE_READ_R0;
23002df8:	ff013097          	auipc	ra,0xff013
23002dfc:	a60080e7          	jalr	-1440(ra) # 22015858 <EF_Ctrl_Load_Efuse_R0>
    uint32_t cnt=0;
23002e00:	4981                	li	s3,0

    tmpVal=BL_RD_REG(EF_DATA_BASE,EF_DATA_0_EF_WIFI_MAC_LOW);
23002e02:	40007737          	lui	a4,0x40007
23002e06:	4b5c                	lw	a5,20(a4)

    /* Get original parity */
    tmpVal=BL_RD_REG(EF_DATA_BASE,EF_DATA_0_EF_KEY_SLOT_5_W2);

    /* Check parity */
    for(i=0;i<8;i++){
23002e08:	4901                	li	s2,0
23002e0a:	4a21                	li	s4,8
    BL_WRWD_TO_BYTEP(maclow,tmpVal);
23002e0c:	0087d693          	srli	a3,a5,0x8
23002e10:	00f40023          	sb	a5,0(s0)
23002e14:	00d400a3          	sb	a3,1(s0)
23002e18:	0107d693          	srli	a3,a5,0x10
23002e1c:	83e1                	srli	a5,a5,0x18
23002e1e:	00d40123          	sb	a3,2(s0)
23002e22:	00f401a3          	sb	a5,3(s0)
    tmpVal=BL_RD_REG(EF_DATA_BASE,EF_DATA_0_EF_WIFI_MAC_HIGH);
23002e26:	4f1c                	lw	a5,24(a4)
    BL_WRWD_TO_BYTEP(machigh,tmpVal);
23002e28:	0087d693          	srli	a3,a5,0x8
23002e2c:	00f40223          	sb	a5,4(s0)
23002e30:	00d402a3          	sb	a3,5(s0)
23002e34:	0107d693          	srli	a3,a5,0x10
23002e38:	83e1                	srli	a5,a5,0x18
23002e3a:	00d40323          	sb	a3,6(s0)
23002e3e:	00f403a3          	sb	a5,7(s0)
    tmpVal=BL_RD_REG(EF_DATA_BASE,EF_DATA_0_EF_KEY_SLOT_5_W2);
23002e42:	5b64                	lw	s1,116(a4)
        cnt+=EF_Ctrl_Get_Byte_Zero_Cnt(mac[i]);
23002e44:	012407b3          	add	a5,s0,s2
23002e48:	0007c503          	lbu	a0,0(a5)
    for(i=0;i<8;i++){
23002e4c:	0905                	addi	s2,s2,1
        cnt+=EF_Ctrl_Get_Byte_Zero_Cnt(mac[i]);
23002e4e:	3741                	jal	23002dce <EF_Ctrl_Get_Byte_Zero_Cnt>
23002e50:	99aa                	add	s3,s3,a0
    for(i=0;i<8;i++){
23002e52:	ff4919e3          	bne	s2,s4,23002e44 <EF_Ctrl_Read_MAC_Address+0x5c>
    if((cnt&0x3f)==(tmpVal&0x3f)){
        return SUCCESS;
    }else{
        return ERROR;
    }
}
23002e56:	40f2                	lw	ra,28(sp)
23002e58:	4462                	lw	s0,24(sp)
    if((cnt&0x3f)==(tmpVal&0x3f)){
23002e5a:	0134c533          	xor	a0,s1,s3
23002e5e:	03f57513          	andi	a0,a0,63
}
23002e62:	44d2                	lw	s1,20(sp)
23002e64:	4942                	lw	s2,16(sp)
23002e66:	49b2                	lw	s3,12(sp)
23002e68:	4a22                	lw	s4,8(sp)
23002e6a:	00a03533          	snez	a0,a0
23002e6e:	6105                	addi	sp,sp,32
23002e70:	8082                	ret

23002e72 <EF_Ctrl_Read_Chip_ID>:
 * @return SUCCESS or ERROR
 *
*******************************************************************************/
BL_Err_Type EF_Ctrl_Read_Chip_ID(uint8_t chipID[8])
{
    return EF_Ctrl_Read_MAC_Address(chipID);
23002e72:	bf9d                	j	23002de8 <EF_Ctrl_Read_MAC_Address>

23002e74 <GLB_Set_USB_CLK>:
*******************************************************************************/
BL_Err_Type GLB_Set_USB_CLK(uint8_t enable)
{
    uint32_t tmpVal = 0;

    tmpVal = BL_RD_REG(GLB_BASE,GLB_CLK_CFG1);
23002e74:	400007b7          	lui	a5,0x40000
23002e78:	43d8                	lw	a4,4(a5)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,GLB_DLL_48M_DIV_EN,1);
23002e7a:	20076713          	ori	a4,a4,512
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG1,tmpVal);
23002e7e:	c3d8                	sw	a4,4(a5)

    tmpVal = BL_RD_REG(GLB_BASE,GLB_CLK_CFG1);
23002e80:	43d8                	lw	a4,4(a5)
    if(enable){
        tmpVal = BL_SET_REG_BIT(tmpVal,GLB_USB_CLK_EN);
    }else{
        tmpVal = BL_CLR_REG_BIT(tmpVal,GLB_USB_CLK_EN);
23002e82:	eff77793          	andi	a5,a4,-257
    if(enable){
23002e86:	c119                	beqz	a0,23002e8c <GLB_Set_USB_CLK+0x18>
        tmpVal = BL_SET_REG_BIT(tmpVal,GLB_USB_CLK_EN);
23002e88:	10076793          	ori	a5,a4,256
    }
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG1,tmpVal);
23002e8c:	40000737          	lui	a4,0x40000
23002e90:	c35c                	sw	a5,4(a4)

    return SUCCESS;
}
23002e92:	4501                	li	a0,0
23002e94:	8082                	ret

23002e96 <GLB_Set_UART_CLK>:
 *
 * @return SUCCESS or ERROR
 *
*******************************************************************************/
BL_Err_Type GLB_Set_UART_CLK(uint8_t enable,HBN_UART_CLK_Type clkSel,uint8_t div)
{
23002e96:	1141                	addi	sp,sp,-16
23002e98:	c422                	sw	s0,8(sp)

    CHECK_PARAM((div<=0x7));
    CHECK_PARAM(IS_HBN_UART_CLK_TYPE(clkSel));

    /* disable UART clock first */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG2);
23002e9a:	40000437          	lui	s0,0x40000
23002e9e:	441c                	lw	a5,8(s0)
{
23002ea0:	c226                	sw	s1,4(sp)
23002ea2:	c606                	sw	ra,12(sp)
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_UART_CLK_EN);
23002ea4:	9bbd                	andi	a5,a5,-17
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG2,tmpVal);
23002ea6:	c41c                	sw	a5,8(s0)

    /* Set div */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG2);
23002ea8:	441c                	lw	a5,8(s0)
{
23002eaa:	84aa                	mv	s1,a0
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_UART_CLK_DIV,div);
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG2,tmpVal);

    /* Select clock source for uart */
    HBN_Set_UART_CLK_Sel(clkSel);
23002eac:	852e                	mv	a0,a1
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_UART_CLK_DIV,div);
23002eae:	9be1                	andi	a5,a5,-8
23002eb0:	8e5d                	or	a2,a2,a5
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG2,tmpVal);
23002eb2:	c410                	sw	a2,8(s0)
    HBN_Set_UART_CLK_Sel(clkSel);
23002eb4:	245d                	jal	2300315a <HBN_Set_UART_CLK_Sel>

    /* Set enable or disable */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG2);
23002eb6:	4418                	lw	a4,8(s0)
    if(enable){
        tmpVal=BL_SET_REG_BIT(tmpVal,GLB_UART_CLK_EN);
23002eb8:	01076793          	ori	a5,a4,16
    if(enable){
23002ebc:	e099                	bnez	s1,23002ec2 <GLB_Set_UART_CLK+0x2c>
23002ebe:	fef77793          	andi	a5,a4,-17
        tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_UART_CLK_EN);
    }
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG2,tmpVal);

    return SUCCESS;
}
23002ec2:	40b2                	lw	ra,12(sp)
23002ec4:	4422                	lw	s0,8(sp)
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG2,tmpVal);
23002ec6:	40000737          	lui	a4,0x40000
23002eca:	c71c                	sw	a5,8(a4)
}
23002ecc:	4492                	lw	s1,4(sp)
23002ece:	4501                	li	a0,0
23002ed0:	0141                	addi	sp,sp,16
23002ed2:	8082                	ret

23002ed4 <GLB_AHB_Slave1_Clock_Gate>:
    /* gate QDEC <=> gate QDEC0 + QDEC1 +QDEC2 + I2S */
    /* gate I2S  <=> gate I2S + QDEC2                */
    
    uint32_t tmpVal = 0;
    
    if((BL_AHB_SLAVE1_GLB==slave1)||(BL_AHB_SLAVE1_TZ2==slave1)|| \
23002ed4:	47b9                	li	a5,14
23002ed6:	00b7ff63          	bgeu	a5,a1,23002ef4 <GLB_AHB_Slave1_Clock_Gate+0x20>
       /* not support */
       return ERROR;
    }
    
    /* gate QDEC and I2S */
    if(BL_AHB_SLAVE1_QDEC==slave1){
23002eda:	47e1                	li	a5,24
23002edc:	02f59563          	bne	a1,a5,23002f06 <GLB_AHB_Slave1_Clock_Gate+0x32>
        tmpVal=BL_RD_REG(GLB_BASE,GLB_CGEN_CFG1);
23002ee0:	400007b7          	lui	a5,0x40000
23002ee4:	53dc                	lw	a5,36(a5)
        if(enable){
            /* clear bit means clock gate */
            tmpVal &=(~(1<<0x18));
            tmpVal &=(~(1<<0x19));
            tmpVal &=(~(1<<0x1A));
23002ee6:	f9000737          	lui	a4,0xf9000
        if(enable){
23002eea:	e139                	bnez	a0,23002f30 <GLB_AHB_Slave1_Clock_Gate+0x5c>
        }else{
            /* set bit means clock pass */
            tmpVal |=(1<<0x18);
            tmpVal |=(1<<0x19);
            tmpVal |=(1<<0x1A);
23002eec:	07000737          	lui	a4,0x7000
        if(enable){
            /* clear bit means clock gate */
            tmpVal &=(~(1<<0x1A));
        }else{
            /* set bit means clock pass */
            tmpVal |=(1<<0x1A);
23002ef0:	8fd9                	or	a5,a5,a4
        }
        BL_WR_REG(GLB_BASE,GLB_CGEN_CFG1,tmpVal);
23002ef2:	a089                	j	23002f34 <GLB_AHB_Slave1_Clock_Gate+0x60>
    if((BL_AHB_SLAVE1_GLB==slave1)||(BL_AHB_SLAVE1_TZ2==slave1)|| \
23002ef4:	6791                	lui	a5,0x4
23002ef6:	34178793          	addi	a5,a5,833 # 4341 <HeapSize+0x3341>
23002efa:	00b7d7b3          	srl	a5,a5,a1
23002efe:	8b85                	andi	a5,a5,1
23002f00:	c3b1                	beqz	a5,23002f44 <GLB_AHB_Slave1_Clock_Gate+0x70>
       return ERROR;
23002f02:	4505                	li	a0,1
23002f04:	8082                	ret
    if(BL_AHB_SLAVE1_KYS==slave1){
23002f06:	47e5                	li	a5,25
23002f08:	00f59b63          	bne	a1,a5,23002f1e <GLB_AHB_Slave1_Clock_Gate+0x4a>
        tmpVal=BL_RD_REG(GLB_BASE,GLB_CGEN_CFG1);
23002f0c:	400007b7          	lui	a5,0x40000
23002f10:	53dc                	lw	a5,36(a5)
            tmpVal &=(~(1<<0x1B));
23002f12:	f8000737          	lui	a4,0xf8000
        if(enable){
23002f16:	ed09                	bnez	a0,23002f30 <GLB_AHB_Slave1_Clock_Gate+0x5c>
            tmpVal |=(1<<0x1B);
23002f18:	08000737          	lui	a4,0x8000
23002f1c:	bfd1                	j	23002ef0 <GLB_AHB_Slave1_Clock_Gate+0x1c>
    if(BL_AHB_SLAVE1_I2S==slave1){
23002f1e:	47e9                	li	a5,26
23002f20:	02f59263          	bne	a1,a5,23002f44 <GLB_AHB_Slave1_Clock_Gate+0x70>
        tmpVal=BL_RD_REG(GLB_BASE,GLB_CGEN_CFG1);
23002f24:	400007b7          	lui	a5,0x40000
23002f28:	53dc                	lw	a5,36(a5)
        if(enable){
23002f2a:	c911                	beqz	a0,23002f3e <GLB_AHB_Slave1_Clock_Gate+0x6a>
            tmpVal &=(~(1<<0x1A));
23002f2c:	fc000737          	lui	a4,0xfc000
23002f30:	177d                	addi	a4,a4,-1
23002f32:	8ff9                	and	a5,a5,a4
        tmpVal &=(~(1<<slave1));
    }else{
        /* set bit means clock pass */
        tmpVal |=(1<<slave1);
    }
    BL_WR_REG(GLB_BASE,GLB_CGEN_CFG1,tmpVal);
23002f34:	40000737          	lui	a4,0x40000
23002f38:	d35c                	sw	a5,36(a4)
    
    return SUCCESS;
23002f3a:	4501                	li	a0,0
}
23002f3c:	8082                	ret
            tmpVal |=(1<<0x1A);
23002f3e:	04000737          	lui	a4,0x4000
23002f42:	b77d                	j	23002ef0 <GLB_AHB_Slave1_Clock_Gate+0x1c>
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CGEN_CFG1);
23002f44:	400007b7          	lui	a5,0x40000
23002f48:	53d8                	lw	a4,36(a5)
    if(enable){
23002f4a:	4785                	li	a5,1
23002f4c:	00b795b3          	sll	a1,a5,a1
        tmpVal |=(1<<slave1);
23002f50:	00e5e7b3          	or	a5,a1,a4
    if(enable){
23002f54:	d165                	beqz	a0,23002f34 <GLB_AHB_Slave1_Clock_Gate+0x60>
        tmpVal &=(~(1<<slave1));
23002f56:	fff5c593          	not	a1,a1
23002f5a:	00e5f7b3          	and	a5,a1,a4
23002f5e:	bfd9                	j	23002f34 <GLB_AHB_Slave1_Clock_Gate+0x60>

23002f60 <GLB_Set_EM_Sel>:
{
    uint32_t tmpVal = 0;

    CHECK_PARAM(IS_GLB_EM_TYPE(emType));

    tmpVal=BL_RD_REG(GLB_BASE,GLB_SEAM_MISC);
23002f60:	40000737          	lui	a4,0x40000
23002f64:	5f7c                	lw	a5,124(a4)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_EM_SEL,emType);
23002f66:	9bc1                	andi	a5,a5,-16
23002f68:	8d5d                	or	a0,a0,a5
    BL_WR_REG(GLB_BASE,GLB_SEAM_MISC,tmpVal);
23002f6a:	df68                	sw	a0,124(a4)

    return SUCCESS;
}
23002f6c:	4501                	li	a0,0
23002f6e:	8082                	ret

23002f70 <GLB_Set_MTimer_CLK>:

    CHECK_PARAM(IS_GLB_MTIMER_CLK_TYPE(clkSel));
    CHECK_PARAM((div<=0x1FFFF));

    /* disable MTimer clock first */
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CPU_CLK_CFG);
23002f70:	40000737          	lui	a4,0x40000
23002f74:	09072683          	lw	a3,144(a4) # 40000090 <__ram_load_addr+0x1cff316c>
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_CPU_RTC_EN);
23002f78:	fffc07b7          	lui	a5,0xfffc0
23002f7c:	17fd                	addi	a5,a5,-1
23002f7e:	8efd                	and	a3,a3,a5
    BL_WR_REG(GLB_BASE,GLB_CPU_CLK_CFG,tmpVal);
23002f80:	08d72823          	sw	a3,144(a4)

    tmpVal=BL_RD_REG(GLB_BASE,GLB_CPU_CLK_CFG);
23002f84:	09072683          	lw	a3,144(a4)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_CPU_RTC_SEL,clkSel);
23002f88:	fff80837          	lui	a6,0xfff80
23002f8c:	187d                	addi	a6,a6,-1
23002f8e:	0106f6b3          	and	a3,a3,a6
23002f92:	05ce                	slli	a1,a1,0x13
23002f94:	8dd5                	or	a1,a1,a3
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_CPU_RTC_DIV,div);
23002f96:	7681                	lui	a3,0xfffe0
23002f98:	8df5                	and	a1,a1,a3
23002f9a:	8e4d                	or	a2,a2,a1
    BL_WR_REG(GLB_BASE,GLB_CPU_CLK_CFG,tmpVal);
23002f9c:	08c72823          	sw	a2,144(a4)

    tmpVal=BL_RD_REG(GLB_BASE,GLB_CPU_CLK_CFG);
23002fa0:	09072703          	lw	a4,144(a4)
    if(enable){
        tmpVal=BL_SET_REG_BIT(tmpVal,GLB_CPU_RTC_EN);
    }else{
        tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_CPU_RTC_EN);
23002fa4:	8ff9                	and	a5,a5,a4
    if(enable){
23002fa6:	c501                	beqz	a0,23002fae <GLB_Set_MTimer_CLK+0x3e>
        tmpVal=BL_SET_REG_BIT(tmpVal,GLB_CPU_RTC_EN);
23002fa8:	000407b7          	lui	a5,0x40
23002fac:	8fd9                	or	a5,a5,a4
    }
    BL_WR_REG(GLB_BASE,GLB_CPU_CLK_CFG,tmpVal);
23002fae:	40000737          	lui	a4,0x40000
23002fb2:	08f72823          	sw	a5,144(a4) # 40000090 <__ram_load_addr+0x1cff316c>

    return SUCCESS;
}
23002fb6:	4501                	li	a0,0
23002fb8:	8082                	ret

23002fba <GLB_UART_Fun_Sel>:
    uint32_t tmpVal=0;

    CHECK_PARAM(IS_GLB_UART_SIG_TYPE(sig));
    CHECK_PARAM(IS_GLB_UART_SIG_FUN_TYPE(fun));

    tmpVal=BL_RD_REG(GLB_BASE,GLB_UART_SIG_SEL_0);
23002fba:	40000737          	lui	a4,0x40000
23002fbe:	0c072683          	lw	a3,192(a4) # 400000c0 <__ram_load_addr+0x1cff319c>
    sig_pos=(sig*4);
23002fc2:	050a                	slli	a0,a0,0x2
    /* Clear original val */
    tmpVal &= (~(0xf<<sig_pos));
23002fc4:	47bd                	li	a5,15
23002fc6:	00a797b3          	sll	a5,a5,a0
23002fca:	fff7c793          	not	a5,a5
    /* Set new value */
    tmpVal |= (fun<<sig_pos);
23002fce:	00a59533          	sll	a0,a1,a0
    tmpVal &= (~(0xf<<sig_pos));
23002fd2:	8ff5                	and	a5,a5,a3
    tmpVal |= (fun<<sig_pos);
23002fd4:	8fc9                	or	a5,a5,a0
    BL_WR_REG(GLB_BASE,GLB_UART_SIG_SEL_0,tmpVal);
23002fd6:	0cf72023          	sw	a5,192(a4)

    return SUCCESS;
}
23002fda:	4501                	li	a0,0
23002fdc:	8082                	ret

23002fde <GLB_GPIO_Write>:
 * @return SUCCESS or ERROR
 *
*******************************************************************************/
BL_Err_Type GLB_GPIO_Write(GLB_GPIO_Type gpioPin,uint32_t val)
{
    if(gpioPin>=32&&gpioPin<=37){
23002fde:	fe050713          	addi	a4,a0,-32
23002fe2:	0ff77693          	andi	a3,a4,255
23002fe6:	4795                	li	a5,5
23002fe8:	00d7ee63          	bltu	a5,a3,23003004 <GLB_GPIO_Write+0x26>
        if(BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO)&(1<<(gpioPin-32))){
23002fec:	400007b7          	lui	a5,0x40000
23002ff0:	0887a683          	lw	a3,136(a5) # 40000088 <__ram_load_addr+0x1cff3164>
23002ff4:	4785                	li	a5,1
23002ff6:	00e797b3          	sll	a5,a5,a4
23002ffa:	8ff5                	and	a5,a5,a3
23002ffc:	c781                	beqz	a5,23003004 <GLB_GPIO_Write+0x26>
            gpioPin-=9;
23002ffe:	155d                	addi	a0,a0,-9
23003000:	0ff57513          	andi	a0,a0,255
        }
    }
    uint32_t *pOut=(uint32_t *)(GLB_BASE+GLB_GPIO_OUTPUT_OFFSET+((gpioPin>>5)<<2));
23003004:	40000737          	lui	a4,0x40000
23003008:	00555793          	srli	a5,a0,0x5
2300300c:	18870713          	addi	a4,a4,392 # 40000188 <__ram_load_addr+0x1cff3264>
23003010:	078a                	slli	a5,a5,0x2
23003012:	97ba                	add	a5,a5,a4
    uint32_t pos=gpioPin%32;
    uint32_t tmpOut;

    tmpOut=*pOut;
23003014:	4705                	li	a4,1
23003016:	4394                	lw	a3,0(a5)
    if(val>0){
23003018:	00a71533          	sll	a0,a4,a0
2300301c:	c589                	beqz	a1,23003026 <GLB_GPIO_Write+0x48>
        tmpOut |= (1<<pos);
2300301e:	8d55                	or	a0,a0,a3
    }else{
        tmpOut &= (~(1<<pos));
    }
    *pOut=tmpOut;
23003020:	c388                	sw	a0,0(a5)

    return SUCCESS;
}
23003022:	4501                	li	a0,0
23003024:	8082                	ret
        tmpOut &= (~(1<<pos));
23003026:	fff54513          	not	a0,a0
2300302a:	8d75                	and	a0,a0,a3
2300302c:	bfd5                	j	23003020 <GLB_GPIO_Write+0x42>

2300302e <GLB_GPIO_IntMask>:
*******************************************************************************/
BL_Err_Type GLB_GPIO_IntMask(GLB_GPIO_Type gpioPin,BL_Mask_Type intMask)
{
    uint32_t tmpVal;

    if(gpioPin<32){
2300302e:	47fd                	li	a5,31
23003030:	02a7e063          	bltu	a5,a0,23003050 <GLB_GPIO_IntMask+0x22>
        /* GPIO0 ~ GPIO31 */
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MASK1);
23003034:	400007b7          	lui	a5,0x40000
23003038:	1a07a783          	lw	a5,416(a5) # 400001a0 <__ram_load_addr+0x1cff327c>
        if(intMask==MASK){
2300303c:	4705                	li	a4,1
2300303e:	00a71533          	sll	a0,a4,a0
23003042:	00e59963          	bne	a1,a4,23003054 <GLB_GPIO_IntMask+0x26>
            tmpVal = tmpVal|(1<<gpioPin);
23003046:	8d5d                	or	a0,a0,a5
        }else{
            tmpVal = tmpVal&~(1<<gpioPin);
        }
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MASK1,tmpVal);
23003048:	400007b7          	lui	a5,0x40000
2300304c:	1aa7a023          	sw	a0,416(a5) # 400001a0 <__ram_load_addr+0x1cff327c>
    }

    return SUCCESS;
}
23003050:	4501                	li	a0,0
23003052:	8082                	ret
            tmpVal = tmpVal&~(1<<gpioPin);
23003054:	fff54513          	not	a0,a0
23003058:	8d7d                	and	a0,a0,a5
2300305a:	b7fd                	j	23003048 <GLB_GPIO_IntMask+0x1a>

2300305c <GLB_GPIO_IntClear>:
*******************************************************************************/
BL_Err_Type GLB_GPIO_IntClear(GLB_GPIO_Type gpioPin,BL_Sts_Type intClear)
{
    uint32_t tmpVal;

    if(gpioPin<32){
2300305c:	47fd                	li	a5,31
2300305e:	02a7e063          	bltu	a5,a0,2300307e <GLB_GPIO_IntClear+0x22>
        /* GPIO0 ~ GPIO31 */
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_CLR1);
23003062:	400007b7          	lui	a5,0x40000
23003066:	1b07a783          	lw	a5,432(a5) # 400001b0 <__ram_load_addr+0x1cff328c>
        if(intClear==SET){
2300306a:	4705                	li	a4,1
2300306c:	00a71533          	sll	a0,a4,a0
23003070:	00e59963          	bne	a1,a4,23003082 <GLB_GPIO_IntClear+0x26>
            tmpVal = tmpVal|(1<<gpioPin);
23003074:	8d5d                	or	a0,a0,a5
        }else{
            tmpVal = tmpVal&~(1<<gpioPin);
        }
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_CLR1,tmpVal);
23003076:	400007b7          	lui	a5,0x40000
2300307a:	1aa7a823          	sw	a0,432(a5) # 400001b0 <__ram_load_addr+0x1cff328c>
    }

    return SUCCESS;
}
2300307e:	4501                	li	a0,0
23003080:	8082                	ret
            tmpVal = tmpVal&~(1<<gpioPin);
23003082:	fff54513          	not	a0,a0
23003086:	8d7d                	and	a0,a0,a5
23003088:	b7fd                	j	23003076 <GLB_GPIO_IntClear+0x1a>

2300308a <GLB_Get_GPIO_IntStatus>:
*******************************************************************************/
BL_Sts_Type GLB_Get_GPIO_IntStatus(GLB_GPIO_Type gpioPin)
{
    uint32_t tmpVal=0;

    if(gpioPin<32){
2300308a:	47fd                	li	a5,31
    uint32_t tmpVal=0;
2300308c:	4701                	li	a4,0
    if(gpioPin<32){
2300308e:	00a7e663          	bltu	a5,a0,2300309a <GLB_Get_GPIO_IntStatus+0x10>
        /* GPIO0 ~ GPIO31 */
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_STAT1);
23003092:	400007b7          	lui	a5,0x40000
23003096:	1a87a703          	lw	a4,424(a5) # 400001a8 <__ram_load_addr+0x1cff3284>
    }

    return (tmpVal&(1<<gpioPin))?SET:RESET;
2300309a:	4785                	li	a5,1
2300309c:	00a79533          	sll	a0,a5,a0
230030a0:	8d79                	and	a0,a0,a4
}
230030a2:	00a03533          	snez	a0,a0
230030a6:	8082                	ret

230030a8 <GLB_Set_GPIO_IntMod>:
    uint32_t tmpGpioPin;

    CHECK_PARAM(IS_GLB_GPIO_INT_CONTROL_TYPE(intCtlMod));
    CHECK_PARAM(IS_GLB_GPIO_INT_TRIG_TYPE(intTrgMod));

    if(gpioPin<GLB_GPIO_PIN_10){
230030a8:	058a                	slli	a1,a1,0x2
230030aa:	47a5                	li	a5,9
230030ac:	8e4d                	or	a2,a2,a1
230030ae:	02a7e663          	bltu	a5,a0,230030da <GLB_Set_GPIO_IntMod+0x32>
        /* GPIO0 ~ GPIO9 */
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET1);
        tmpGpioPin = gpioPin;
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
230030b2:	478d                	li	a5,3
230030b4:	02f50533          	mul	a0,a0,a5
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET1);
230030b8:	40000737          	lui	a4,0x40000
230030bc:	1c072683          	lw	a3,448(a4) # 400001c0 <__ram_load_addr+0x1cff329c>
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
230030c0:	479d                	li	a5,7
230030c2:	00a797b3          	sll	a5,a5,a0
230030c6:	fff7c793          	not	a5,a5
230030ca:	8ff5                	and	a5,a5,a3
230030cc:	00a61533          	sll	a0,a2,a0
230030d0:	8d5d                	or	a0,a0,a5
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET1,tmpVal);
230030d2:	1ca72023          	sw	a0,448(a4)
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET4,tmpVal);
    }

    return SUCCESS;
}
230030d6:	4501                	li	a0,0
230030d8:	8082                	ret
    }else if(gpioPin<GLB_GPIO_PIN_20){
230030da:	47cd                	li	a5,19
230030dc:	02a7e663          	bltu	a5,a0,23003108 <GLB_Set_GPIO_IntMod+0x60>
        tmpGpioPin = gpioPin - GLB_GPIO_PIN_10;
230030e0:	1559                	addi	a0,a0,-10
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
230030e2:	470d                	li	a4,3
230030e4:	02e50733          	mul	a4,a0,a4
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET2);
230030e8:	400006b7          	lui	a3,0x40000
230030ec:	1c46a583          	lw	a1,452(a3) # 400001c4 <__ram_load_addr+0x1cff32a0>
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
230030f0:	479d                	li	a5,7
230030f2:	00e797b3          	sll	a5,a5,a4
230030f6:	fff7c793          	not	a5,a5
230030fa:	8fed                	and	a5,a5,a1
230030fc:	00e61733          	sll	a4,a2,a4
23003100:	8f5d                	or	a4,a4,a5
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET2,tmpVal);
23003102:	1ce6a223          	sw	a4,452(a3)
23003106:	bfc1                	j	230030d6 <GLB_Set_GPIO_IntMod+0x2e>
    }else if(gpioPin<GLB_GPIO_PIN_30){
23003108:	47f5                	li	a5,29
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET3);
2300310a:	40000737          	lui	a4,0x40000
    }else if(gpioPin<GLB_GPIO_PIN_30){
2300310e:	02a7e463          	bltu	a5,a0,23003136 <GLB_Set_GPIO_IntMod+0x8e>
        tmpGpioPin = gpioPin - GLB_GPIO_PIN_20;
23003112:	1531                	addi	a0,a0,-20
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
23003114:	478d                	li	a5,3
23003116:	02f507b3          	mul	a5,a0,a5
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET3);
2300311a:	1c872683          	lw	a3,456(a4) # 400001c8 <__ram_load_addr+0x1cff32a4>
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
2300311e:	451d                	li	a0,7
23003120:	00f51533          	sll	a0,a0,a5
23003124:	fff54513          	not	a0,a0
23003128:	8d75                	and	a0,a0,a3
2300312a:	00f617b3          	sll	a5,a2,a5
2300312e:	8fc9                	or	a5,a5,a0
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET3,tmpVal);
23003130:	1cf72423          	sw	a5,456(a4)
23003134:	b74d                	j	230030d6 <GLB_Set_GPIO_IntMod+0x2e>
        tmpGpioPin = gpioPin - GLB_GPIO_PIN_30;
23003136:	1509                	addi	a0,a0,-30
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
23003138:	458d                	li	a1,3
2300313a:	02b50533          	mul	a0,a0,a1
        tmpVal = BL_RD_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET4);
2300313e:	1cc72683          	lw	a3,460(a4)
        tmpVal = (tmpVal&~(0x7<<(3*tmpGpioPin)))|(((intCtlMod<<2)|intTrgMod)<<(3*tmpGpioPin));
23003142:	479d                	li	a5,7
23003144:	00a797b3          	sll	a5,a5,a0
23003148:	fff7c793          	not	a5,a5
2300314c:	8ff5                	and	a5,a5,a3
2300314e:	00a61533          	sll	a0,a2,a0
23003152:	8d5d                	or	a0,a0,a5
        BL_WR_REG(GLB_BASE,GLB_GPIO_INT_MODE_SET4,tmpVal);
23003154:	1ca72623          	sw	a0,460(a4)
23003158:	bfbd                	j	230030d6 <GLB_Set_GPIO_IntMod+0x2e>

2300315a <HBN_Set_UART_CLK_Sel>:
{
    uint32_t tmpVal;
    
    CHECK_PARAM(IS_HBN_UART_CLK_TYPE(clkSel));
    
    tmpVal=BL_RD_REG(HBN_BASE,HBN_GLB);
2300315a:	4000f737          	lui	a4,0x4000f
2300315e:	5b1c                	lw	a5,48(a4)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_UART_CLK_SEL,clkSel);
23003160:	050a                	slli	a0,a0,0x2
23003162:	9bed                	andi	a5,a5,-5
23003164:	8d5d                	or	a0,a0,a5
    BL_WR_REG(HBN_BASE,HBN_GLB,tmpVal);
23003166:	db08                	sw	a0,48(a4)
    
    return SUCCESS;
}
23003168:	4501                	li	a0,0
2300316a:	8082                	ret

2300316c <HBN_Enable_BOR_IRQ>:
*******************************************************************************/
BL_Err_Type HBN_Enable_BOR_IRQ(void)
{
    uint32_t tmpVal;
    
    tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
2300316c:	4000f737          	lui	a4,0x4000f
23003170:	4b5c                	lw	a5,20(a4)
    tmpVal=BL_SET_REG_BIT(tmpVal,HBN_IRQ_BOR_EN);
23003172:	000406b7          	lui	a3,0x40
    BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
    
    return SUCCESS;
}
23003176:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BIT(tmpVal,HBN_IRQ_BOR_EN);
23003178:	8fd5                	or	a5,a5,a3
    BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
2300317a:	cb5c                	sw	a5,20(a4)
}
2300317c:	8082                	ret

2300317e <HBN_Disable_BOR_IRQ>:
*******************************************************************************/
BL_Err_Type HBN_Disable_BOR_IRQ(void)
{
    uint32_t tmpVal;
    
    tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
2300317e:	4000f6b7          	lui	a3,0x4000f
23003182:	4adc                	lw	a5,20(a3)
    tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_IRQ_BOR_EN);
23003184:	fffc0737          	lui	a4,0xfffc0
23003188:	177d                	addi	a4,a4,-1
2300318a:	8ff9                	and	a5,a5,a4
    BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
2300318c:	cadc                	sw	a5,20(a3)
    
    return SUCCESS;
}
2300318e:	4501                	li	a0,0
23003190:	8082                	ret

23003192 <HBN_Set_BOR_Cfg>:
 *
 * @return SUCCESS or ERROR
 *
*******************************************************************************/
BL_Err_Type HBN_Set_BOR_Cfg(HBN_BOR_CFG_Type *cfg)
{
23003192:	1141                	addi	sp,sp,-16
23003194:	c422                	sw	s0,8(sp)
23003196:	c606                	sw	ra,12(sp)
    uint32_t tmpVal = 0;

    if(cfg->enableBorInt){
23003198:	00154783          	lbu	a5,1(a0)
{
2300319c:	842a                	mv	s0,a0
    if(cfg->enableBorInt){
2300319e:	c3a9                	beqz	a5,230031e0 <HBN_Set_BOR_Cfg+0x4e>
        HBN_Enable_BOR_IRQ();
230031a0:	37f1                	jal	2300316c <HBN_Enable_BOR_IRQ>
    }else{
        HBN_Disable_BOR_IRQ();
    }

    tmpVal=BL_RD_REG(HBN_BASE,HBN_MISC);
230031a2:	4000f7b7          	lui	a5,0x4000f
230031a6:	57dc                	lw	a5,44(a5)

    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_BOR_VTH,cfg->borThreshold);
    if(cfg->enablePorInBor){
230031a8:	00344683          	lbu	a3,3(s0) # 40000003 <__ram_load_addr+0x1cff30df>
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_BOR_VTH,cfg->borThreshold);
230031ac:	ffd7f713          	andi	a4,a5,-3
230031b0:	00244783          	lbu	a5,2(s0)
230031b4:	0786                	slli	a5,a5,0x1
230031b6:	8fd9                	or	a5,a5,a4
        tmpVal=BL_SET_REG_BIT(tmpVal,HBN_BOR_SEL);
    }else{
        tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_BOR_SEL);
230031b8:	ffe7f713          	andi	a4,a5,-2
    if(cfg->enablePorInBor){
230031bc:	c299                	beqz	a3,230031c2 <HBN_Set_BOR_Cfg+0x30>
        tmpVal=BL_SET_REG_BIT(tmpVal,HBN_BOR_SEL);
230031be:	0017e713          	ori	a4,a5,1
    }

    if(cfg->enableBor){
230031c2:	00044683          	lbu	a3,0(s0)
        tmpVal=BL_SET_REG_BIT(tmpVal,HBN_PU_BOR);
    }else{
        tmpVal=BL_CLR_REG_BIT(tmpVal,HBN_PU_BOR);
230031c6:	ffb77793          	andi	a5,a4,-5
    if(cfg->enableBor){
230031ca:	c299                	beqz	a3,230031d0 <HBN_Set_BOR_Cfg+0x3e>
        tmpVal=BL_SET_REG_BIT(tmpVal,HBN_PU_BOR);
230031cc:	00476793          	ori	a5,a4,4
    }

    BL_WR_REG(HBN_BASE,HBN_MISC,tmpVal);

    return SUCCESS;
}
230031d0:	40b2                	lw	ra,12(sp)
230031d2:	4422                	lw	s0,8(sp)
    BL_WR_REG(HBN_BASE,HBN_MISC,tmpVal);
230031d4:	4000f737          	lui	a4,0x4000f
230031d8:	d75c                	sw	a5,44(a4)
}
230031da:	4501                	li	a0,0
230031dc:	0141                	addi	sp,sp,16
230031de:	8082                	ret
        HBN_Disable_BOR_IRQ();
230031e0:	3f79                	jal	2300317e <HBN_Disable_BOR_IRQ>
230031e2:	b7c1                	j	230031a2 <HBN_Set_BOR_Cfg+0x10>

230031e4 <UART_IntHandler>:
#ifndef BFLB_USE_HAL_DRIVER
static void UART_IntHandler(UART_ID_Type uartId)
{
    uint32_t tmpVal = 0;
    uint32_t maskVal = 0;
    uint32_t UARTx = uartAddr[uartId];
230031e4:	230067b7          	lui	a5,0x23006
230031e8:	00251713          	slli	a4,a0,0x2
230031ec:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
{
230031f0:	1101                	addi	sp,sp,-32
    uint32_t UARTx = uartAddr[uartId];
230031f2:	97ba                	add	a5,a5,a4
{
230031f4:	c64e                	sw	s3,12(sp)
    uint32_t UARTx = uartAddr[uartId];
230031f6:	0007a983          	lw	s3,0(a5)
{
230031fa:	c84a                	sw	s2,16(sp)
230031fc:	ca26                	sw	s1,20(sp)

    tmpVal = BL_RD_REG(UARTx,UART_INT_STS);
230031fe:	0209a903          	lw	s2,32(s3)
    maskVal = BL_RD_REG(UARTx,UART_INT_MASK);
23003202:	0249a483          	lw	s1,36(s3)
{
23003206:	cc22                	sw	s0,24(sp)
23003208:	ce06                	sw	ra,28(sp)

    /* Length of uart tx data transfer arrived interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_UTX_END_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_UTX_END_MASK)){
2300320a:	00197793          	andi	a5,s2,1
{
2300320e:	842a                	mv	s0,a0
    if(BL_IS_REG_BIT_SET(tmpVal,UART_UTX_END_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_UTX_END_MASK)){
23003210:	c39d                	beqz	a5,23003236 <UART_IntHandler+0x52>
23003212:	0014f793          	andi	a5,s1,1
23003216:	e385                	bnez	a5,23003236 <UART_IntHandler+0x52>
        BL_WR_REG(UARTx,UART_INT_CLEAR,0x1);
23003218:	4785                	li	a5,1
2300321a:	02f9a423          	sw	a5,40(s3)
        if(uartIntCbfArra[uartId][UART_INT_TX_END] != NULL){
2300321e:	02400793          	li	a5,36
23003222:	02f50733          	mul	a4,a0,a5
23003226:	420247b7          	lui	a5,0x42024
2300322a:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
2300322e:	97ba                	add	a5,a5,a4
23003230:	439c                	lw	a5,0(a5)
23003232:	c391                	beqz	a5,23003236 <UART_IntHandler+0x52>
            uartIntCbfArra[uartId][UART_INT_TX_END]();
23003234:	9782                	jalr	a5
        }
    }

    /* Length of uart rx data transfer arrived interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_END_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_END_MASK)){
23003236:	00297793          	andi	a5,s2,2
2300323a:	c39d                	beqz	a5,23003260 <UART_IntHandler+0x7c>
2300323c:	0024f793          	andi	a5,s1,2
23003240:	e385                	bnez	a5,23003260 <UART_IntHandler+0x7c>
        BL_WR_REG(UARTx,UART_INT_CLEAR,0x2);
23003242:	4789                	li	a5,2
23003244:	02f9a423          	sw	a5,40(s3)
        if(uartIntCbfArra[uartId][UART_INT_RX_END] != NULL){
23003248:	02400793          	li	a5,36
2300324c:	02f40733          	mul	a4,s0,a5
23003250:	420247b7          	lui	a5,0x42024
23003254:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
23003258:	97ba                	add	a5,a5,a4
2300325a:	43dc                	lw	a5,4(a5)
2300325c:	c391                	beqz	a5,23003260 <UART_IntHandler+0x7c>
            uartIntCbfArra[uartId][UART_INT_RX_END]();
2300325e:	9782                	jalr	a5
        }
    }

    /* Tx fifo ready interrupt,auto-cleared when data is pushed */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_UTX_FIFO_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_UTX_FIFO_MASK)){
23003260:	00497793          	andi	a5,s2,4
23003264:	c385                	beqz	a5,23003284 <UART_IntHandler+0xa0>
23003266:	0044f793          	andi	a5,s1,4
2300326a:	ef89                	bnez	a5,23003284 <UART_IntHandler+0xa0>
        if(uartIntCbfArra[uartId][UART_INT_TX_FIFO_REQ] != NULL){
2300326c:	02400793          	li	a5,36
23003270:	02f40733          	mul	a4,s0,a5
23003274:	420247b7          	lui	a5,0x42024
23003278:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
2300327c:	97ba                	add	a5,a5,a4
2300327e:	479c                	lw	a5,8(a5)
23003280:	c391                	beqz	a5,23003284 <UART_IntHandler+0xa0>
            uartIntCbfArra[uartId][UART_INT_TX_FIFO_REQ]();
23003282:	9782                	jalr	a5
        }
    }

    /* Rx fifo ready interrupt,auto-cleared when data is popped */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_FIFO_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_FIFO_MASK)){
23003284:	00897793          	andi	a5,s2,8
23003288:	c385                	beqz	a5,230032a8 <UART_IntHandler+0xc4>
2300328a:	0084f793          	andi	a5,s1,8
2300328e:	ef89                	bnez	a5,230032a8 <UART_IntHandler+0xc4>
        if(uartIntCbfArra[uartId][UART_INT_RX_FIFO_REQ] != NULL){
23003290:	02400793          	li	a5,36
23003294:	02f40733          	mul	a4,s0,a5
23003298:	420247b7          	lui	a5,0x42024
2300329c:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
230032a0:	97ba                	add	a5,a5,a4
230032a2:	47dc                	lw	a5,12(a5)
230032a4:	c391                	beqz	a5,230032a8 <UART_IntHandler+0xc4>
            uartIntCbfArra[uartId][UART_INT_RX_FIFO_REQ]();
230032a6:	9782                	jalr	a5
        }
    }

    /* Rx time-out interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_RTO_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_RTO_MASK)){
230032a8:	01097793          	andi	a5,s2,16
230032ac:	c39d                	beqz	a5,230032d2 <UART_IntHandler+0xee>
230032ae:	0104f793          	andi	a5,s1,16
230032b2:	e385                	bnez	a5,230032d2 <UART_IntHandler+0xee>
        BL_WR_REG(UARTx,UART_INT_CLEAR,0x10);
230032b4:	47c1                	li	a5,16
230032b6:	02f9a423          	sw	a5,40(s3)
        if(uartIntCbfArra[uartId][UART_INT_RTO] != NULL){
230032ba:	02400793          	li	a5,36
230032be:	02f40733          	mul	a4,s0,a5
230032c2:	420247b7          	lui	a5,0x42024
230032c6:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
230032ca:	97ba                	add	a5,a5,a4
230032cc:	4b9c                	lw	a5,16(a5)
230032ce:	c391                	beqz	a5,230032d2 <UART_IntHandler+0xee>
            uartIntCbfArra[uartId][UART_INT_RTO]();
230032d0:	9782                	jalr	a5
        }
    }

    /* Rx parity check error interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_PCE_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_PCE_MASK)){
230032d2:	02097793          	andi	a5,s2,32
230032d6:	c785                	beqz	a5,230032fe <UART_IntHandler+0x11a>
230032d8:	0204f793          	andi	a5,s1,32
230032dc:	e38d                	bnez	a5,230032fe <UART_IntHandler+0x11a>
        BL_WR_REG(UARTx,UART_INT_CLEAR,0x20);
230032de:	02000793          	li	a5,32
230032e2:	02f9a423          	sw	a5,40(s3)
        if(uartIntCbfArra[uartId][UART_INT_PCE] != NULL){
230032e6:	02400793          	li	a5,36
230032ea:	02f40733          	mul	a4,s0,a5
230032ee:	420247b7          	lui	a5,0x42024
230032f2:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
230032f6:	97ba                	add	a5,a5,a4
230032f8:	4bdc                	lw	a5,20(a5)
230032fa:	c391                	beqz	a5,230032fe <UART_IntHandler+0x11a>
            uartIntCbfArra[uartId][UART_INT_PCE]();
230032fc:	9782                	jalr	a5
        }
    }

    /* Tx fifo overflow/underflow error interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_UTX_FER_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_UTX_FER_MASK)){
230032fe:	04097793          	andi	a5,s2,64
23003302:	c385                	beqz	a5,23003322 <UART_IntHandler+0x13e>
23003304:	0404f793          	andi	a5,s1,64
23003308:	ef89                	bnez	a5,23003322 <UART_IntHandler+0x13e>
        if(uartIntCbfArra[uartId][UART_INT_TX_FER] != NULL){
2300330a:	02400793          	li	a5,36
2300330e:	02f40733          	mul	a4,s0,a5
23003312:	420247b7          	lui	a5,0x42024
23003316:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
2300331a:	97ba                	add	a5,a5,a4
2300331c:	4f9c                	lw	a5,24(a5)
2300331e:	c391                	beqz	a5,23003322 <UART_IntHandler+0x13e>
            uartIntCbfArra[uartId][UART_INT_TX_FER]();
23003320:	9782                	jalr	a5
        }
    }

    /* Rx fifo overflow/underflow error interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_FER_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_FER_MASK)){
23003322:	08097793          	andi	a5,s2,128
23003326:	c385                	beqz	a5,23003346 <UART_IntHandler+0x162>
23003328:	0804f793          	andi	a5,s1,128
2300332c:	ef89                	bnez	a5,23003346 <UART_IntHandler+0x162>
        if(uartIntCbfArra[uartId][UART_INT_RX_FER] != NULL){
2300332e:	02400793          	li	a5,36
23003332:	02f40733          	mul	a4,s0,a5
23003336:	420247b7          	lui	a5,0x42024
2300333a:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
2300333e:	97ba                	add	a5,a5,a4
23003340:	4fdc                	lw	a5,28(a5)
23003342:	c391                	beqz	a5,23003346 <UART_IntHandler+0x162>
            uartIntCbfArra[uartId][UART_INT_RX_FER]();
23003344:	9782                	jalr	a5
        }
    }

    /* Rx lin mode sync field error interrupt */
    if(BL_IS_REG_BIT_SET(tmpVal,UART_URX_LSE_INT) && !BL_IS_REG_BIT_SET(maskVal,UART_CR_URX_LSE_MASK)){
23003346:	10097913          	andi	s2,s2,256
2300334a:	02090d63          	beqz	s2,23003384 <UART_IntHandler+0x1a0>
2300334e:	1004f493          	andi	s1,s1,256
23003352:	e88d                	bnez	s1,23003384 <UART_IntHandler+0x1a0>
        BL_WR_REG(UARTx,UART_INT_CLEAR,0x100);
23003354:	10000793          	li	a5,256
23003358:	02f9a423          	sw	a5,40(s3)
        if(uartIntCbfArra[uartId][UART_INT_LSE] != NULL){
2300335c:	02400793          	li	a5,36
23003360:	02f40433          	mul	s0,s0,a5
23003364:	420247b7          	lui	a5,0x42024
23003368:	5f078793          	addi	a5,a5,1520 # 420245f0 <uartIntCbfArra>
2300336c:	943e                	add	s0,s0,a5
2300336e:	02042303          	lw	t1,32(s0)
23003372:	00030963          	beqz	t1,23003384 <UART_IntHandler+0x1a0>
            uartIntCbfArra[uartId][UART_INT_LSE]();
        }
    }
}
23003376:	4462                	lw	s0,24(sp)
23003378:	40f2                	lw	ra,28(sp)
2300337a:	44d2                	lw	s1,20(sp)
2300337c:	4942                	lw	s2,16(sp)
2300337e:	49b2                	lw	s3,12(sp)
23003380:	6105                	addi	sp,sp,32
            uartIntCbfArra[uartId][UART_INT_LSE]();
23003382:	8302                	jr	t1
}
23003384:	40f2                	lw	ra,28(sp)
23003386:	4462                	lw	s0,24(sp)
23003388:	44d2                	lw	s1,20(sp)
2300338a:	4942                	lw	s2,16(sp)
2300338c:	49b2                	lw	s3,12(sp)
2300338e:	6105                	addi	sp,sp,32
23003390:	8082                	ret

23003392 <UART0_IRQHandler>:
 *
*******************************************************************************/
#ifndef BFLB_USE_HAL_DRIVER
void UART0_IRQHandler(void)
{
    UART_IntHandler(UART0_ID);
23003392:	4501                	li	a0,0
23003394:	bd81                	j	230031e4 <UART_IntHandler>

23003396 <UART1_IRQHandler>:
 *
*******************************************************************************/
#ifndef BFLB_USE_HAL_DRIVER
void UART1_IRQHandler(void)
{
    UART_IntHandler(UART1_ID);
23003396:	4505                	li	a0,1
23003398:	b5b1                	j	230031e4 <UART_IntHandler>

2300339a <UART_Init>:
    uint32_t UARTx = uartAddr[uartId];
2300339a:	050a                	slli	a0,a0,0x2
2300339c:	230067b7          	lui	a5,0x23006
230033a0:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
230033a4:	97aa                	add	a5,a5,a0
    fraction = uartCfg->uartClk * 10 / uartCfg->baudRate % 10;
230033a6:	4198                	lw	a4,0(a1)
230033a8:	41c8                	lw	a0,4(a1)
230033aa:	46a9                	li	a3,10
    uint32_t UARTx = uartAddr[uartId];
230033ac:	4390                	lw	a2,0(a5)
    baudRateDivisor = uartCfg->uartClk / uartCfg->baudRate;
230033ae:	02a757b3          	divu	a5,a4,a0
{
230033b2:	1141                	addi	sp,sp,-16
230033b4:	c606                	sw	ra,12(sp)
    fraction = uartCfg->uartClk * 10 / uartCfg->baudRate % 10;
230033b6:	02d70733          	mul	a4,a4,a3
230033ba:	02a75733          	divu	a4,a4,a0
230033be:	02d77733          	remu	a4,a4,a3
    if(fraction >= 5){
230033c2:	4691                	li	a3,4
230033c4:	00e6f363          	bgeu	a3,a4,230033ca <UART_Init+0x30>
        ++baudRateDivisor;
230033c8:	0785                	addi	a5,a5,1
    BL_WR_REG(UARTx,UART_BIT_PRD,((baudRateDivisor-1)<<0x10)|((baudRateDivisor-1)&0xFFFF));
230033ca:	17fd                	addi	a5,a5,-1
230033cc:	01079713          	slli	a4,a5,0x10
230033d0:	07c2                	slli	a5,a5,0x10
230033d2:	83c1                	srli	a5,a5,0x10
230033d4:	8fd9                	or	a5,a5,a4
230033d6:	c61c                	sw	a5,8(a2)
    switch(uartCfg->parity)
230033d8:	00a5c683          	lbu	a3,10(a1)
    tmpValTxCfg = BL_RD_REG(UARTx,UART_UTX_CONFIG);
230033dc:	421c                	lw	a5,0(a2)
    tmpValRxCfg = BL_RD_REG(UARTx,UART_URX_CONFIG);
230033de:	4258                	lw	a4,4(a2)
    switch(uartCfg->parity)
230033e0:	4505                	li	a0,1
230033e2:	0ca68663          	beq	a3,a0,230034ae <UART_Init+0x114>
230033e6:	c2e9                	beqz	a3,230034a8 <UART_Init+0x10e>
230033e8:	4509                	li	a0,2
230033ea:	0ca68763          	beq	a3,a0,230034b8 <UART_Init+0x11e>
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_D,(uartCfg->dataBits+4));
230033ee:	0085c683          	lbu	a3,8(a1)
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_P,(uartCfg->stopBits+1));
230033f2:	7579                	lui	a0,0xffffe
230033f4:	7ff50513          	addi	a0,a0,2047 # ffffe7ff <__HeapLimit+0xbdfd27ff>
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_D,(uartCfg->dataBits+4));
230033f8:	0691                	addi	a3,a3,4
230033fa:	06a2                	slli	a3,a3,0x8
230033fc:	8ff7f793          	andi	a5,a5,-1793
23003400:	8fd5                	or	a5,a5,a3
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_P,(uartCfg->stopBits+1));
23003402:	8fe9                	and	a5,a5,a0
23003404:	0095c503          	lbu	a0,9(a1)
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_BIT_CNT_D,(uartCfg->dataBits+4));
23003408:	8ff77713          	andi	a4,a4,-1793
2300340c:	8f55                	or	a4,a4,a3
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_P,(uartCfg->stopBits+1));
2300340e:	0505                	addi	a0,a0,1
23003410:	052e                	slli	a0,a0,0xb
23003412:	8fc9                	or	a5,a5,a0
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_CTS_EN,uartCfg->ctsFlowControl);
23003414:	00b5c503          	lbu	a0,11(a1)
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_DEG_EN,uartCfg->rxDeglitch);
23003418:	76fd                	lui	a3,0xfffff
2300341a:	7ff68693          	addi	a3,a3,2047 # fffff7ff <__HeapLimit+0xbdfd37ff>
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_CTS_EN,uartCfg->ctsFlowControl);
2300341e:	0506                	slli	a0,a0,0x1
23003420:	9bf5                	andi	a5,a5,-3
23003422:	8fc9                	or	a5,a5,a0
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_DEG_EN,uartCfg->rxDeglitch);
23003424:	8f75                	and	a4,a4,a3
23003426:	00c5c683          	lbu	a3,12(a1)
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_LIN_EN,uartCfg->txLinMode);
2300342a:	ff77f513          	andi	a0,a5,-9
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_LIN_EN,uartCfg->rxLinMode);
2300342e:	0105c783          	lbu	a5,16(a1)
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_DEG_EN,uartCfg->rxDeglitch);
23003432:	06ae                	slli	a3,a3,0xb
23003434:	8f55                	or	a4,a4,a3
    tmpValRxCfg = BL_SET_REG_BITS_VAL(tmpValRxCfg,UART_CR_URX_LIN_EN,uartCfg->rxLinMode);
23003436:	078e                	slli	a5,a5,0x3
23003438:	9b5d                	andi	a4,a4,-9
2300343a:	8f5d                	or	a4,a4,a5
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_LIN_EN,uartCfg->txLinMode);
2300343c:	00f5c783          	lbu	a5,15(a1)
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_B,uartCfg->txBreakBitCnt);
23003440:	76c9                	lui	a3,0xffff2
23003442:	16fd                	addi	a3,a3,-1
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_LIN_EN,uartCfg->txLinMode);
23003444:	078e                	slli	a5,a5,0x3
23003446:	8fc9                	or	a5,a5,a0
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_B,uartCfg->txBreakBitCnt);
23003448:	8ff5                	and	a5,a5,a3
2300344a:	0115c683          	lbu	a3,17(a1)
    if(UART_MSB_FIRST == uartCfg->byteBitInverse){
2300344e:	0125c503          	lbu	a0,18(a1)
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_BIT_CNT_B,uartCfg->txBreakBitCnt);
23003452:	06b6                	slli	a3,a3,0xd
23003454:	8fd5                	or	a5,a5,a3
    BL_WR_REG(UARTx,UART_UTX_CONFIG,tmpValTxCfg);
23003456:	c21c                	sw	a5,0(a2)
    if(UART_MSB_FIRST == uartCfg->byteBitInverse){
23003458:	4685                	li	a3,1
    BL_WR_REG(UARTx,UART_URX_CONFIG,tmpValRxCfg);
2300345a:	c258                	sw	a4,4(a2)
    tmpValTxCfg = BL_RD_REG(UARTx,UART_DATA_CONFIG);
2300345c:	4658                	lw	a4,12(a2)
        tmpValTxCfg = BL_CLR_REG_BIT(tmpValTxCfg,UART_CR_UART_BIT_INV);
2300345e:	ffe77793          	andi	a5,a4,-2
    if(UART_MSB_FIRST == uartCfg->byteBitInverse){
23003462:	00d51463          	bne	a0,a3,2300346a <UART_Init+0xd0>
        tmpValTxCfg = BL_SET_REG_BIT(tmpValTxCfg,UART_CR_UART_BIT_INV);
23003466:	00176793          	ori	a5,a4,1
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_URX_RTS_SW_MODE,uartCfg->rtsSoftwareControl);
2300346a:	00d5c703          	lbu	a4,13(a1)
    BL_WR_REG(UARTx,UART_DATA_CONFIG,tmpValTxCfg);
2300346e:	c65c                	sw	a5,12(a2)
    tmpValTxCfg = BL_RD_REG(UARTx,UART_SW_MODE);
23003470:	4e5c                	lw	a5,28(a2)
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_URX_RTS_SW_MODE,uartCfg->rtsSoftwareControl);
23003472:	070a                	slli	a4,a4,0x2
    Interrupt_Handler_Register(UART0_IRQn,UART0_IRQHandler);
23003474:	02d00513          	li	a0,45
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_URX_RTS_SW_MODE,uartCfg->rtsSoftwareControl);
23003478:	9be9                	andi	a5,a5,-6
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_TXD_SW_MODE,uartCfg->txSoftwareControl);
2300347a:	8fd9                	or	a5,a5,a4
2300347c:	00e5c703          	lbu	a4,14(a1)
    Interrupt_Handler_Register(UART0_IRQn,UART0_IRQHandler);
23003480:	230035b7          	lui	a1,0x23003
23003484:	39258593          	addi	a1,a1,914 # 23003392 <UART0_IRQHandler>
    tmpValTxCfg = BL_SET_REG_BITS_VAL(tmpValTxCfg,UART_CR_UTX_TXD_SW_MODE,uartCfg->txSoftwareControl);
23003488:	8fd9                	or	a5,a5,a4
    BL_WR_REG(UARTx,UART_SW_MODE,tmpValTxCfg);
2300348a:	ce5c                	sw	a5,28(a2)
    Interrupt_Handler_Register(UART0_IRQn,UART0_IRQHandler);
2300348c:	ec2ff0ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
    Interrupt_Handler_Register(UART1_IRQn,UART1_IRQHandler);
23003490:	230035b7          	lui	a1,0x23003
23003494:	02e00513          	li	a0,46
23003498:	39658593          	addi	a1,a1,918 # 23003396 <UART1_IRQHandler>
2300349c:	eb2ff0ef          	jal	ra,23002b4e <Interrupt_Handler_Register>
}
230034a0:	40b2                	lw	ra,12(sp)
230034a2:	4501                	li	a0,0
230034a4:	0141                	addi	sp,sp,16
230034a6:	8082                	ret
            tmpValTxCfg = BL_CLR_REG_BIT(tmpValTxCfg,UART_CR_UTX_PRT_EN);
230034a8:	9bbd                	andi	a5,a5,-17
            tmpValRxCfg = BL_CLR_REG_BIT(tmpValRxCfg,UART_CR_URX_PRT_EN);
230034aa:	9b3d                	andi	a4,a4,-17
            break;
230034ac:	b789                	j	230033ee <UART_Init+0x54>
            tmpValTxCfg = BL_SET_REG_BIT(tmpValTxCfg,UART_CR_UTX_PRT_SEL);
230034ae:	0307e793          	ori	a5,a5,48
            tmpValRxCfg = BL_SET_REG_BIT(tmpValRxCfg,UART_CR_URX_PRT_SEL);
230034b2:	03076713          	ori	a4,a4,48
            break;
230034b6:	bf25                	j	230033ee <UART_Init+0x54>
            tmpValTxCfg = BL_CLR_REG_BIT(tmpValTxCfg,UART_CR_UTX_PRT_SEL);
230034b8:	fdf7f793          	andi	a5,a5,-33
230034bc:	fdf77713          	andi	a4,a4,-33
230034c0:	0107e793          	ori	a5,a5,16
            tmpValRxCfg = BL_CLR_REG_BIT(tmpValRxCfg,UART_CR_URX_PRT_SEL);
230034c4:	01076713          	ori	a4,a4,16
            break;
230034c8:	b71d                	j	230033ee <UART_Init+0x54>

230034ca <UART_FifoConfig>:
    uint32_t UARTx = uartAddr[uartId];
230034ca:	230067b7          	lui	a5,0x23006
230034ce:	050a                	slli	a0,a0,0x2
230034d0:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
230034d4:	97aa                	add	a5,a5,a0
230034d6:	4394                	lw	a3,0(a5)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,UART_TX_FIFO_TH,fifoCfg->txFifoDmaThreshold-1);
230034d8:	ff810737          	lui	a4,0xff810
230034dc:	177d                	addi	a4,a4,-1
    tmpVal = BL_RD_REG(UARTx,UART_FIFO_CONFIG_1);
230034de:	0846a783          	lw	a5,132(a3) # ffff2084 <__HeapLimit+0xbdfc6084>
    if(ENABLE == fifoCfg->txFifoDmaEnable){
230034e2:	0025c503          	lbu	a0,2(a1)
230034e6:	4605                	li	a2,1
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,UART_TX_FIFO_TH,fifoCfg->txFifoDmaThreshold-1);
230034e8:	8f7d                	and	a4,a4,a5
230034ea:	0005c783          	lbu	a5,0(a1)
230034ee:	17fd                	addi	a5,a5,-1
230034f0:	07c2                	slli	a5,a5,0x10
230034f2:	8fd9                	or	a5,a5,a4
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,UART_RX_FIFO_TH,fifoCfg->rxFifoDmaThreshold-1);
230034f4:	81000737          	lui	a4,0x81000
230034f8:	177d                	addi	a4,a4,-1
230034fa:	8ff9                	and	a5,a5,a4
230034fc:	0015c703          	lbu	a4,1(a1)
23003500:	177d                	addi	a4,a4,-1
23003502:	0762                	slli	a4,a4,0x18
23003504:	8fd9                	or	a5,a5,a4
    BL_WR_REG(UARTx,UART_FIFO_CONFIG_1,tmpVal);
23003506:	08f6a223          	sw	a5,132(a3)
    tmpVal = BL_RD_REG(UARTx,UART_FIFO_CONFIG_0);
2300350a:	0806a703          	lw	a4,128(a3)
        tmpVal = BL_CLR_REG_BIT(tmpVal,UART_DMA_TX_EN);
2300350e:	ffe77793          	andi	a5,a4,-2
    if(ENABLE == fifoCfg->txFifoDmaEnable){
23003512:	00c51463          	bne	a0,a2,2300351a <UART_FifoConfig+0x50>
        tmpVal = BL_SET_REG_BIT(tmpVal,UART_DMA_TX_EN);
23003516:	00176793          	ori	a5,a4,1
    if(ENABLE == fifoCfg->rxFifoDmaEnable){
2300351a:	0035c583          	lbu	a1,3(a1)
2300351e:	4605                	li	a2,1
        tmpVal = BL_CLR_REG_BIT(tmpVal,UART_DMA_RX_EN);
23003520:	ffd7f713          	andi	a4,a5,-3
    if(ENABLE == fifoCfg->rxFifoDmaEnable){
23003524:	00c59463          	bne	a1,a2,2300352c <UART_FifoConfig+0x62>
        tmpVal = BL_SET_REG_BIT(tmpVal,UART_DMA_RX_EN);
23003528:	0027e713          	ori	a4,a5,2
    BL_WR_REG(UARTx,UART_FIFO_CONFIG_0,tmpVal);
2300352c:	08e6a023          	sw	a4,128(a3)
}
23003530:	4501                	li	a0,0
23003532:	8082                	ret

23003534 <UART_Enable>:
    uint32_t UARTx = uartAddr[uartId];
23003534:	230067b7          	lui	a5,0x23006
23003538:	050a                	slli	a0,a0,0x2
2300353a:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
2300353e:	97aa                	add	a5,a5,a0
    if(direct == UART_TX || direct == UART_TXRX){
23003540:	0fd5f713          	andi	a4,a1,253
    uint32_t UARTx = uartAddr[uartId];
23003544:	439c                	lw	a5,0(a5)
    if(direct == UART_TX || direct == UART_TXRX){
23003546:	e709                	bnez	a4,23003550 <UART_Enable+0x1c>
        tmpVal = BL_RD_REG(UARTx,UART_UTX_CONFIG);
23003548:	4398                	lw	a4,0(a5)
        BL_WR_REG(UARTx,UART_UTX_CONFIG,BL_SET_REG_BIT(tmpVal,UART_CR_UTX_EN));
2300354a:	00176713          	ori	a4,a4,1
2300354e:	c398                	sw	a4,0(a5)
    if(direct == UART_RX || direct == UART_TXRX){
23003550:	15fd                	addi	a1,a1,-1
23003552:	0ff5f593          	andi	a1,a1,255
23003556:	4705                	li	a4,1
23003558:	00b76663          	bltu	a4,a1,23003564 <UART_Enable+0x30>
        tmpVal = BL_RD_REG(UARTx,UART_URX_CONFIG);
2300355c:	43d8                	lw	a4,4(a5)
        BL_WR_REG(UARTx,UART_URX_CONFIG,BL_SET_REG_BIT(tmpVal,UART_CR_URX_EN));
2300355e:	00176713          	ori	a4,a4,1
23003562:	c3d8                	sw	a4,4(a5)
}
23003564:	4501                	li	a0,0
23003566:	8082                	ret

23003568 <UART_Disable>:
    uint32_t UARTx = uartAddr[uartId];
23003568:	230067b7          	lui	a5,0x23006
2300356c:	050a                	slli	a0,a0,0x2
2300356e:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
23003572:	97aa                	add	a5,a5,a0
    if(direct == UART_TX || direct == UART_TXRX){
23003574:	0fd5f713          	andi	a4,a1,253
    uint32_t UARTx = uartAddr[uartId];
23003578:	439c                	lw	a5,0(a5)
    if(direct == UART_TX || direct == UART_TXRX){
2300357a:	e701                	bnez	a4,23003582 <UART_Disable+0x1a>
        tmpVal = BL_RD_REG(UARTx,UART_UTX_CONFIG);
2300357c:	4398                	lw	a4,0(a5)
        BL_WR_REG(UARTx,UART_UTX_CONFIG,BL_CLR_REG_BIT(tmpVal,UART_CR_UTX_EN));
2300357e:	9b79                	andi	a4,a4,-2
23003580:	c398                	sw	a4,0(a5)
    if(direct == UART_RX || direct == UART_TXRX){
23003582:	15fd                	addi	a1,a1,-1
23003584:	0ff5f593          	andi	a1,a1,255
23003588:	4705                	li	a4,1
2300358a:	00b76563          	bltu	a4,a1,23003594 <UART_Disable+0x2c>
        tmpVal = BL_RD_REG(UARTx,UART_URX_CONFIG);
2300358e:	43d8                	lw	a4,4(a5)
        BL_WR_REG(UARTx,UART_URX_CONFIG,BL_CLR_REG_BIT(tmpVal,UART_CR_URX_EN));
23003590:	9b79                	andi	a4,a4,-2
23003592:	c3d8                	sw	a4,4(a5)
}
23003594:	4501                	li	a0,0
23003596:	8082                	ret

23003598 <UART_SetRxTimeoutValue>:
    uint32_t UARTx = uartAddr[uartId];
23003598:	230067b7          	lui	a5,0x23006
2300359c:	050a                	slli	a0,a0,0x2
2300359e:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
230035a2:	97aa                	add	a5,a5,a0
    tmpVal = BL_RD_REG(UARTx,UART_URX_RTO_TIMER);
230035a4:	4398                	lw	a4,0(a5)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,UART_CR_URX_RTO_VALUE,time-1);
230035a6:	15fd                	addi	a1,a1,-1
}
230035a8:	4501                	li	a0,0
    tmpVal = BL_RD_REG(UARTx,UART_URX_RTO_TIMER);
230035aa:	4f1c                	lw	a5,24(a4)
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,UART_CR_URX_RTO_VALUE,time-1);
230035ac:	f007f793          	andi	a5,a5,-256
230035b0:	8ddd                	or	a1,a1,a5
    BL_WR_REG(UARTx,UART_URX_RTO_TIMER,tmpVal);
230035b2:	cf0c                	sw	a1,24(a4)
}
230035b4:	8082                	ret

230035b6 <UART_TxFreeRun>:
    uint32_t UARTx = uartAddr[uartId];
230035b6:	230067b7          	lui	a5,0x23006
230035ba:	050a                	slli	a0,a0,0x2
230035bc:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
230035c0:	97aa                	add	a5,a5,a0
    tmpVal = BL_RD_REG(UARTx,UART_UTX_CONFIG);
230035c2:	4398                	lw	a4,0(a5)
    if(ENABLE == txFreeRun){
230035c4:	4685                	li	a3,1
    tmpVal = BL_RD_REG(UARTx,UART_UTX_CONFIG);
230035c6:	431c                	lw	a5,0(a4)
    if(ENABLE == txFreeRun){
230035c8:	00d59763          	bne	a1,a3,230035d6 <UART_TxFreeRun+0x20>
        BL_WR_REG(UARTx,UART_UTX_CONFIG,BL_SET_REG_BIT(tmpVal,UART_CR_UTX_FRM_EN));
230035cc:	0047e793          	ori	a5,a5,4
        BL_WR_REG(UARTx,UART_UTX_CONFIG,BL_CLR_REG_BIT(tmpVal,UART_CR_UTX_FRM_EN));
230035d0:	c31c                	sw	a5,0(a4)
}
230035d2:	4501                	li	a0,0
230035d4:	8082                	ret
        BL_WR_REG(UARTx,UART_UTX_CONFIG,BL_CLR_REG_BIT(tmpVal,UART_CR_UTX_FRM_EN));
230035d6:	9bed                	andi	a5,a5,-5
230035d8:	bfe5                	j	230035d0 <UART_TxFreeRun+0x1a>

230035da <UART_IntMask>:
    uint32_t UARTx = uartAddr[uartId];
230035da:	230067b7          	lui	a5,0x23006
230035de:	050a                	slli	a0,a0,0x2
230035e0:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
230035e4:	97aa                	add	a5,a5,a0
    tmpVal = BL_RD_REG(UARTx,UART_INT_MASK);
230035e6:	4398                	lw	a4,0(a5)
    if(UART_INT_ALL == intType){
230035e8:	46a5                	li	a3,9
    tmpVal = BL_RD_REG(UARTx,UART_INT_MASK);
230035ea:	535c                	lw	a5,36(a4)
    if(UART_INT_ALL == intType){
230035ec:	00d59b63          	bne	a1,a3,23003602 <UART_IntMask+0x28>
        if(MASK == intMask){
230035f0:	4685                	li	a3,1
            tmpVal &= 0;
230035f2:	4581                	li	a1,0
        if(MASK == intMask){
230035f4:	00d61463          	bne	a2,a3,230035fc <UART_IntMask+0x22>
            tmpVal |= 0x1ff;
230035f8:	1ff7e593          	ori	a1,a5,511
    BL_WR_REG(UARTx,UART_INT_MASK,tmpVal);
230035fc:	d34c                	sw	a1,36(a4)
}
230035fe:	4501                	li	a0,0
23003600:	8082                	ret
        if(MASK == intMask){
23003602:	4685                	li	a3,1
23003604:	00b695b3          	sll	a1,a3,a1
23003608:	00d61463          	bne	a2,a3,23003610 <UART_IntMask+0x36>
            tmpVal |= 1<<intType;
2300360c:	8ddd                	or	a1,a1,a5
2300360e:	b7fd                	j	230035fc <UART_IntMask+0x22>
            tmpVal &= ~(1<<intType);
23003610:	fff5c593          	not	a1,a1
23003614:	8dfd                	and	a1,a1,a5
23003616:	b7dd                	j	230035fc <UART_IntMask+0x22>

23003618 <UART_SendData>:
    uint32_t UARTx = uartAddr[uartId];
23003618:	230067b7          	lui	a5,0x23006
2300361c:	050a                	slli	a0,a0,0x2
2300361e:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
23003622:	97aa                	add	a5,a5,a0
23003624:	4388                	lw	a0,0(a5)
    uint32_t timeoutCnt = UART_TX_TIMEOUT_COUNT;
23003626:	000277b7          	lui	a5,0x27
2300362a:	10078793          	addi	a5,a5,256 # 27100 <HeapSize+0x26100>
    uint32_t txLen = 0;
2300362e:	4701                	li	a4,0
            timeoutCnt = UART_TX_TIMEOUT_COUNT;
23003630:	00027837          	lui	a6,0x27
    while(txLen<len){
23003634:	00c76463          	bltu	a4,a2,2300363c <UART_SendData+0x24>
    return SUCCESS;
23003638:	4501                	li	a0,0
2300363a:	8082                	ret
    return BL_GET_REG_BITS_VAL(BL_RD_REG(UARTx,UART_FIFO_CONFIG_1),UART_TX_FIFO_CNT);
2300363c:	08452683          	lw	a3,132(a0)
        if(UART_GetTxFifoCount(uartId)>0){
23003640:	0ff6f693          	andi	a3,a3,255
23003644:	ca99                	beqz	a3,2300365a <UART_SendData+0x42>
            BL_WR_BYTE(UARTx+UART_FIFO_WDATA_OFFSET,data[txLen++]);
23003646:	00e587b3          	add	a5,a1,a4
2300364a:	0007c783          	lbu	a5,0(a5)
2300364e:	0705                	addi	a4,a4,1
23003650:	08f50423          	sb	a5,136(a0)
            timeoutCnt = UART_TX_TIMEOUT_COUNT;
23003654:	10080793          	addi	a5,a6,256 # 27100 <HeapSize+0x26100>
23003658:	bff1                	j	23003634 <UART_SendData+0x1c>
            timeoutCnt--;
2300365a:	17fd                	addi	a5,a5,-1
            if(timeoutCnt == 0){
2300365c:	ffe1                	bnez	a5,23003634 <UART_SendData+0x1c>
                return TIMEOUT;
2300365e:	4509                	li	a0,2
}
23003660:	8082                	ret

23003662 <UART_GetTxFifoCount>:
    uint32_t UARTx = uartAddr[uartId];
23003662:	230067b7          	lui	a5,0x23006
23003666:	050a                	slli	a0,a0,0x2
23003668:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
2300366c:	97aa                	add	a5,a5,a0
    return BL_GET_REG_BITS_VAL(BL_RD_REG(UARTx,UART_FIFO_CONFIG_1),UART_TX_FIFO_CNT);
2300366e:	439c                	lw	a5,0(a5)
23003670:	0847a503          	lw	a0,132(a5)
}
23003674:	0ff57513          	andi	a0,a0,255
23003678:	8082                	ret

2300367a <USB_Enable>:

BL_Err_Type USB_Enable(void)
{
    uint32_t tmpVal = 0;
    
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
2300367a:	4000e737          	lui	a4,0x4000e
2300367e:	80072783          	lw	a5,-2048(a4) # 4000d800 <__ram_load_addr+0x1d0008dc>
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EN);
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
    
    return SUCCESS;
}
23003682:	4501                	li	a0,0
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EN);
23003684:	0017e793          	ori	a5,a5,1
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003688:	80f72023          	sw	a5,-2048(a4)
}
2300368c:	8082                	ret

2300368e <USB_Disable>:

BL_Err_Type USB_Disable(void)
{
    uint32_t tmpVal = 0;
    
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
2300368e:	4000e737          	lui	a4,0x4000e
23003692:	80072783          	lw	a5,-2048(a4) # 4000d800 <__ram_load_addr+0x1d0008dc>
    tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EN);
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
    
    return SUCCESS;
}
23003696:	4501                	li	a0,0
    tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EN);
23003698:	9bf9                	andi	a5,a5,-2
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
2300369a:	80f72023          	sw	a5,-2048(a4)
}
2300369e:	8082                	ret

230036a0 <USB_Set_Config>:
BL_Err_Type USB_Set_Config(BL_Fun_Type enable,USB_Config_Type * usbCfg)
{
    uint32_t tmpVal=0;
    
    /* disable USB first */
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
230036a0:	4000e7b7          	lui	a5,0x4000e
230036a4:	8007a703          	lw	a4,-2048(a5) # 4000d800 <__ram_load_addr+0x1d0008dc>
    tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EN);
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
    
    /* USB config */
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
    if(usbCfg->SoftwareCtrl==ENABLE){
230036a8:	0045c603          	lbu	a2,4(a1)
    tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EN);
230036ac:	9b79                	andi	a4,a4,-2
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
230036ae:	80e7a023          	sw	a4,-2048(a5)
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
230036b2:	0055c703          	lbu	a4,5(a1)
230036b6:	8007a683          	lw	a3,-2048(a5)
    if(usbCfg->SoftwareCtrl==ENABLE){
230036ba:	4785                	li	a5,1
230036bc:	0712                	slli	a4,a4,0x4
230036be:	06f61563          	bne	a2,a5,23003728 <USB_Set_Config+0x88>
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_CTRL);
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_ADDR,usbCfg->DeviceAddress);
230036c2:	0035c783          	lbu	a5,3(a1)
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_SIZE,usbCfg->EnumMaxPacketSize);
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_NACK_IN,usbCfg->EnumInEn);
230036c6:	7641                	lui	a2,0xffff0
230036c8:	1ff60613          	addi	a2,a2,511 # ffff01ff <__HeapLimit+0xbdfc41ff>
230036cc:	8ef1                	and	a3,a3,a2
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_ADDR,usbCfg->DeviceAddress);
230036ce:	07a6                	slli	a5,a5,0x9
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_NACK_IN,usbCfg->EnumInEn);
230036d0:	8fd5                	or	a5,a5,a3
230036d2:	ff0106b7          	lui	a3,0xff010
230036d6:	16fd                	addi	a3,a3,-1
230036d8:	8ff5                	and	a5,a5,a3
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_SIZE,usbCfg->EnumMaxPacketSize);
230036da:	0025c683          	lbu	a3,2(a1)
230036de:	06c2                	slli	a3,a3,0x10
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_NACK_IN,usbCfg->EnumInEn);
230036e0:	8fd5                	or	a5,a5,a3
230036e2:	fe0006b7          	lui	a3,0xfe000
230036e6:	16fd                	addi	a3,a3,-1
230036e8:	8ff5                	and	a5,a5,a3
230036ea:	0015c683          	lbu	a3,1(a1)
230036ee:	1007e793          	ori	a5,a5,256
230036f2:	06e6                	slli	a3,a3,0x19
230036f4:	8fd5                	or	a5,a5,a3
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_NACK_OUT,usbCfg->EnumOutEn);
230036f6:	fc0006b7          	lui	a3,0xfc000
230036fa:	16fd                	addi	a3,a3,-1
230036fc:	8efd                	and	a3,a3,a5
230036fe:	0005c783          	lbu	a5,0(a1)
23003702:	07ea                	slli	a5,a5,0x1a
23003704:	8fd5                	or	a5,a5,a3
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_ROM_DCT_EN,usbCfg->RomBaseDescriptorUsed);
23003706:	9bbd                	andi	a5,a5,-17
23003708:	8f5d                	or	a4,a4,a5
    }else{
        tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_CTRL);
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_ROM_DCT_EN,usbCfg->RomBaseDescriptorUsed);
    }
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
2300370a:	4000e7b7          	lui	a5,0x4000e
2300370e:	80e7a023          	sw	a4,-2048(a5) # 4000d800 <__ram_load_addr+0x1d0008dc>
    
    /* enable/disable USB */
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
23003712:	8007a783          	lw	a5,-2048(a5)
    if(enable){
23003716:	c119                	beqz	a0,2300371c <USB_Set_Config+0x7c>
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EN);
23003718:	0017e793          	ori	a5,a5,1
    }
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
2300371c:	4000e737          	lui	a4,0x4000e
23003720:	80f72023          	sw	a5,-2048(a4) # 4000d800 <__ram_load_addr+0x1d0008dc>
    
    return SUCCESS;
}
23003724:	4501                	li	a0,0
23003726:	8082                	ret
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_ROM_DCT_EN,usbCfg->RomBaseDescriptorUsed);
23003728:	eef6f693          	andi	a3,a3,-273
2300372c:	8f55                	or	a4,a4,a3
2300372e:	bff1                	j	2300370a <USB_Set_Config+0x6a>

23003730 <USB_Set_Device_Addr>:

BL_Err_Type USB_Set_Device_Addr(uint8_t addr)
{
    uint32_t tmpVal = 0;
    
    tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
23003730:	4000e6b7          	lui	a3,0x4000e
23003734:	8006a783          	lw	a5,-2048(a3) # 4000d800 <__ram_load_addr+0x1d0008dc>
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_ADDR,addr);
23003738:	7741                	lui	a4,0xffff0
2300373a:	1ff70713          	addi	a4,a4,511 # ffff01ff <__HeapLimit+0xbdfc41ff>
2300373e:	8ff9                	and	a5,a5,a4
23003740:	0526                	slli	a0,a0,0x9
23003742:	8d5d                	or	a0,a0,a5
    BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003744:	80a6a023          	sw	a0,-2048(a3)
    
    return SUCCESS;
}
23003748:	4501                	li	a0,0
2300374a:	8082                	ret

2300374c <USB_Set_EPx_Xfer_Size>:

BL_Err_Type USB_Set_EPx_Xfer_Size(USB_EP_ID epId,uint8_t size)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
2300374c:	ed19                	bnez	a0,2300376a <USB_Set_EPx_Xfer_Size+0x1e>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
2300374e:	4000e6b7          	lui	a3,0x4000e
23003752:	8006a783          	lw	a5,-2048(a3) # 4000d800 <__ram_load_addr+0x1d0008dc>
        tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_USB_EP0_SW_SIZE,size);
23003756:	ff010737          	lui	a4,0xff010
2300375a:	177d                	addi	a4,a4,-1
2300375c:	8ff9                	and	a5,a5,a4
2300375e:	05c2                	slli	a1,a1,0x10
23003760:	8ddd                	or	a1,a1,a5
        BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003762:	80b6a023          	sw	a1,-2048(a3)
                break;
        }
    }
    
    return SUCCESS;
}
23003766:	4501                	li	a0,0
23003768:	8082                	ret
        switch(epId){
2300376a:	157d                	addi	a0,a0,-1
2300376c:	0ff57513          	andi	a0,a0,255
23003770:	4799                	li	a5,6
23003772:	fea7eae3          	bltu	a5,a0,23003766 <USB_Set_EPx_Xfer_Size+0x1a>
23003776:	230067b7          	lui	a5,0x23006
2300377a:	13478793          	addi	a5,a5,308 # 23006134 <uartAddr+0x8>
2300377e:	050a                	slli	a0,a0,0x2
23003780:	953e                	add	a0,a0,a5
23003782:	411c                	lw	a5,0(a0)
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003784:	4000e737          	lui	a4,0x4000e
        switch(epId){
23003788:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
2300378a:	84072783          	lw	a5,-1984(a4) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_SIZE,size);
2300378e:	8007f793          	andi	a5,a5,-2048
23003792:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
23003794:	84b72023          	sw	a1,-1984(a4)
                break;
23003798:	b7f9                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
2300379a:	84472783          	lw	a5,-1980(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_SIZE,size);
2300379e:	8007f793          	andi	a5,a5,-2048
230037a2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
230037a4:	84b72223          	sw	a1,-1980(a4)
                break;
230037a8:	bf7d                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
230037aa:	84872783          	lw	a5,-1976(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_SIZE,size);
230037ae:	8007f793          	andi	a5,a5,-2048
230037b2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
230037b4:	84b72423          	sw	a1,-1976(a4)
                break;
230037b8:	b77d                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
230037ba:	84c72783          	lw	a5,-1972(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_SIZE,size);
230037be:	8007f793          	andi	a5,a5,-2048
230037c2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
230037c4:	84b72623          	sw	a1,-1972(a4)
                break;
230037c8:	bf79                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
230037ca:	85072783          	lw	a5,-1968(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_SIZE,size);
230037ce:	8007f793          	andi	a5,a5,-2048
230037d2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
230037d4:	84b72823          	sw	a1,-1968(a4)
                break;
230037d8:	b779                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
230037da:	85472783          	lw	a5,-1964(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_SIZE,size);
230037de:	8007f793          	andi	a5,a5,-2048
230037e2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
230037e4:	84b72a23          	sw	a1,-1964(a4)
                break;
230037e8:	bfbd                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
230037ea:	85872783          	lw	a5,-1960(a4)
                tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_SIZE,size);
230037ee:	8007f793          	andi	a5,a5,-2048
230037f2:	8ddd                	or	a1,a1,a5
                BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
230037f4:	84b72c23          	sw	a1,-1960(a4)
                break;
230037f8:	b7bd                	j	23003766 <USB_Set_EPx_Xfer_Size+0x1a>

230037fa <USB_Set_EPx_Rdy>:

BL_Err_Type USB_Set_EPx_Rdy(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
230037fa:	e105                	bnez	a0,2300381a <USB_Set_EPx_Rdy+0x20>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
230037fc:	4000e6b7          	lui	a3,0x4000e
23003800:	8006a783          	lw	a5,-2048(a3) # 4000d800 <__ram_load_addr+0x1d0008dc>
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_RDY);
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_NACK_OUT);
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_NACK_IN);
        tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_STALL);
23003804:	ff000737          	lui	a4,0xff000
23003808:	177d                	addi	a4,a4,-1
2300380a:	8ff9                	and	a5,a5,a4
2300380c:	0e000737          	lui	a4,0xe000
23003810:	8fd9                	or	a5,a5,a4
        BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003812:	80f6a023          	sw	a5,-2048(a3)
                break;
        }
    }
    
    return SUCCESS;
}
23003816:	4501                	li	a0,0
23003818:	8082                	ret
        switch(epId){
2300381a:	157d                	addi	a0,a0,-1
2300381c:	0ff57513          	andi	a0,a0,255
23003820:	4799                	li	a5,6
23003822:	fea7eae3          	bltu	a5,a0,23003816 <USB_Set_EPx_Rdy+0x1c>
23003826:	230067b7          	lui	a5,0x23006
2300382a:	15078793          	addi	a5,a5,336 # 23006150 <uartAddr+0x24>
2300382e:	050a                	slli	a0,a0,0x2
23003830:	953e                	add	a0,a0,a5
23003832:	4118                	lw	a4,0(a0)
23003834:	77c1                	lui	a5,0xffff0
23003836:	17fd                	addi	a5,a5,-1
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003838:	4000e6b7          	lui	a3,0x4000e
        switch(epId){
2300383c:	8702                	jr	a4
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
2300383e:	8406a703          	lw	a4,-1984(a3) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP1_STALL);
23003842:	8ff9                	and	a5,a5,a4
23003844:	00060737          	lui	a4,0x60
23003848:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
2300384a:	84f6a023          	sw	a5,-1984(a3)
                break;
2300384e:	b7e1                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
23003850:	8446a703          	lw	a4,-1980(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP2_STALL);
23003854:	8ff9                	and	a5,a5,a4
23003856:	00060737          	lui	a4,0x60
2300385a:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
2300385c:	84f6a223          	sw	a5,-1980(a3)
                break;
23003860:	bf5d                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003862:	8486a703          	lw	a4,-1976(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP3_STALL);
23003866:	8ff9                	and	a5,a5,a4
23003868:	00060737          	lui	a4,0x60
2300386c:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
2300386e:	84f6a423          	sw	a5,-1976(a3)
                break;
23003872:	b755                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003874:	84c6a703          	lw	a4,-1972(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP4_STALL);
23003878:	8ff9                	and	a5,a5,a4
2300387a:	00060737          	lui	a4,0x60
2300387e:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
23003880:	84f6a623          	sw	a5,-1972(a3)
                break;
23003884:	bf49                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003886:	8506a703          	lw	a4,-1968(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP5_STALL);
2300388a:	8ff9                	and	a5,a5,a4
2300388c:	00060737          	lui	a4,0x60
23003890:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
23003892:	84f6a823          	sw	a5,-1968(a3)
                break;
23003896:	b741                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003898:	8546a703          	lw	a4,-1964(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP6_STALL);
2300389c:	8ff9                	and	a5,a5,a4
2300389e:	00060737          	lui	a4,0x60
230038a2:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
230038a4:	84f6aa23          	sw	a5,-1964(a3)
                break;
230038a8:	b7bd                	j	23003816 <USB_Set_EPx_Rdy+0x1c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
230038aa:	8586a703          	lw	a4,-1960(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP7_STALL);
230038ae:	8ff9                	and	a5,a5,a4
230038b0:	00060737          	lui	a4,0x60
230038b4:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
230038b6:	84f6ac23          	sw	a5,-1960(a3)
                break;
230038ba:	bfb1                	j	23003816 <USB_Set_EPx_Rdy+0x1c>

230038bc <USB_Is_EPx_RDY_Free>:

BL_Sts_Type USB_Is_EPx_RDY_Free(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;

    if(epId == EP_ID0){
230038bc:	e911                	bnez	a0,230038d0 <USB_Is_EPx_RDY_Free+0x14>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
230038be:	4000e7b7          	lui	a5,0x4000e
230038c2:	8007a503          	lw	a0,-2048(a5) # 4000d800 <__ram_load_addr+0x1d0008dc>
        tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_USB_EP0_SW_RDY);
230038c6:	8171                	srli	a0,a0,0x1c
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP6_RDY);
                break;

            case EP_ID7:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP7_RDY);
230038c8:	8905                	andi	a0,a0,1
                break;
        }
    }

    return tmpVal?RESET:SET;
}
230038ca:	00154513          	xori	a0,a0,1
230038ce:	8082                	ret
        switch(epId){
230038d0:	157d                	addi	a0,a0,-1
230038d2:	0ff57793          	andi	a5,a0,255
230038d6:	4719                	li	a4,6
    uint32_t tmpVal = 0;
230038d8:	4501                	li	a0,0
        switch(epId){
230038da:	fef768e3          	bltu	a4,a5,230038ca <USB_Is_EPx_RDY_Free+0xe>
230038de:	23006737          	lui	a4,0x23006
230038e2:	078a                	slli	a5,a5,0x2
230038e4:	16c70713          	addi	a4,a4,364 # 2300616c <uartAddr+0x40>
230038e8:	97ba                	add	a5,a5,a4
230038ea:	439c                	lw	a5,0(a5)
230038ec:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
230038ee:	4000e7b7          	lui	a5,0x4000e
230038f2:	8407a503          	lw	a0,-1984(a5) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP7_RDY);
230038f6:	814d                	srli	a0,a0,0x13
230038f8:	bfc1                	j	230038c8 <USB_Is_EPx_RDY_Free+0xc>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
230038fa:	4000e7b7          	lui	a5,0x4000e
230038fe:	8447a503          	lw	a0,-1980(a5) # 4000d844 <__ram_load_addr+0x1d000920>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP2_RDY);
23003902:	bfd5                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003904:	4000e7b7          	lui	a5,0x4000e
23003908:	8487a503          	lw	a0,-1976(a5) # 4000d848 <__ram_load_addr+0x1d000924>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP3_RDY);
2300390c:	b7ed                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
2300390e:	4000e7b7          	lui	a5,0x4000e
23003912:	84c7a503          	lw	a0,-1972(a5) # 4000d84c <__ram_load_addr+0x1d000928>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP4_RDY);
23003916:	b7c5                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003918:	4000e7b7          	lui	a5,0x4000e
2300391c:	8507a503          	lw	a0,-1968(a5) # 4000d850 <__ram_load_addr+0x1d00092c>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP5_RDY);
23003920:	bfd9                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003922:	4000e7b7          	lui	a5,0x4000e
23003926:	8547a503          	lw	a0,-1964(a5) # 4000d854 <__ram_load_addr+0x1d000930>
                tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_STS_EP6_RDY);
2300392a:	b7f1                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
2300392c:	4000e7b7          	lui	a5,0x4000e
23003930:	8587a503          	lw	a0,-1960(a5) # 4000d858 <__ram_load_addr+0x1d000934>
23003934:	b7c9                	j	230038f6 <USB_Is_EPx_RDY_Free+0x3a>

23003936 <USB_Set_EPx_STALL>:

BL_Err_Type USB_Set_EPx_STALL(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
23003936:	ed01                	bnez	a0,2300394e <USB_Set_EPx_STALL+0x18>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
23003938:	4000e737          	lui	a4,0x4000e
2300393c:	80072783          	lw	a5,-2048(a4) # 4000d800 <__ram_load_addr+0x1d0008dc>
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_STALL);
23003940:	010006b7          	lui	a3,0x1000
23003944:	8fd5                	or	a5,a5,a3
        BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003946:	80f72023          	sw	a5,-2048(a4)
                break;
        }
    }
    
    return SUCCESS;
}
2300394a:	4501                	li	a0,0
2300394c:	8082                	ret
        switch(epId){
2300394e:	157d                	addi	a0,a0,-1
23003950:	0ff57513          	andi	a0,a0,255
23003954:	4799                	li	a5,6
23003956:	fea7eae3          	bltu	a5,a0,2300394a <USB_Set_EPx_STALL+0x14>
2300395a:	230067b7          	lui	a5,0x23006
2300395e:	18878793          	addi	a5,a5,392 # 23006188 <uartAddr+0x5c>
23003962:	050a                	slli	a0,a0,0x2
23003964:	953e                	add	a0,a0,a5
23003966:	411c                	lw	a5,0(a0)
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003968:	4000e737          	lui	a4,0x4000e
        switch(epId){
2300396c:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
2300396e:	84072783          	lw	a5,-1984(a4) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP1_STALL);
23003972:	66c1                	lui	a3,0x10
23003974:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
23003976:	84f72023          	sw	a5,-1984(a4)
                break;
2300397a:	bfc1                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
2300397c:	84472783          	lw	a5,-1980(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP2_STALL);
23003980:	66c1                	lui	a3,0x10
23003982:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
23003984:	84f72223          	sw	a5,-1980(a4)
                break;
23003988:	b7c9                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
2300398a:	84872783          	lw	a5,-1976(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP3_STALL);
2300398e:	66c1                	lui	a3,0x10
23003990:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
23003992:	84f72423          	sw	a5,-1976(a4)
                break;
23003996:	bf55                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003998:	84c72783          	lw	a5,-1972(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP4_STALL);
2300399c:	66c1                	lui	a3,0x10
2300399e:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
230039a0:	84f72623          	sw	a5,-1972(a4)
                break;
230039a4:	b75d                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
230039a6:	85072783          	lw	a5,-1968(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP5_STALL);
230039aa:	66c1                	lui	a3,0x10
230039ac:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
230039ae:	84f72823          	sw	a5,-1968(a4)
                break;
230039b2:	bf61                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
230039b4:	85472783          	lw	a5,-1964(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP6_STALL);
230039b8:	66c1                	lui	a3,0x10
230039ba:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
230039bc:	84f72a23          	sw	a5,-1964(a4)
                break;
230039c0:	b769                	j	2300394a <USB_Set_EPx_STALL+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
230039c2:	85872783          	lw	a5,-1960(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_EP7_STALL);
230039c6:	66c1                	lui	a3,0x10
230039c8:	8fd5                	or	a5,a5,a3
                BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
230039ca:	84f72c23          	sw	a5,-1960(a4)
                break;
230039ce:	bfb5                	j	2300394a <USB_Set_EPx_STALL+0x14>

230039d0 <USB_Clr_EPx_STALL>:

BL_Err_Type USB_Clr_EPx_STALL(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
230039d0:	c905                	beqz	a0,23003a00 <USB_Clr_EPx_STALL+0x30>
        return SUCCESS;
    }else{
        switch(epId){
230039d2:	157d                	addi	a0,a0,-1
230039d4:	0ff57513          	andi	a0,a0,255
230039d8:	4799                	li	a5,6
230039da:	02a7e363          	bltu	a5,a0,23003a00 <USB_Clr_EPx_STALL+0x30>
230039de:	230067b7          	lui	a5,0x23006
230039e2:	1a478793          	addi	a5,a5,420 # 230061a4 <uartAddr+0x78>
230039e6:	050a                	slli	a0,a0,0x2
230039e8:	953e                	add	a0,a0,a5
230039ea:	4118                	lw	a4,0(a0)
230039ec:	77c1                	lui	a5,0xffff0
230039ee:	17fd                	addi	a5,a5,-1
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP6_STALL);
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
                break;

            case EP_ID7:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
230039f0:	4000e6b7          	lui	a3,0x4000e
        switch(epId){
230039f4:	8702                	jr	a4
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
230039f6:	8406a703          	lw	a4,-1984(a3) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP1_STALL);
230039fa:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
230039fc:	84f6a023          	sw	a5,-1984(a3)
                break;
        }
    }
    
    return SUCCESS;
}
23003a00:	4501                	li	a0,0
23003a02:	8082                	ret
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
23003a04:	8446a703          	lw	a4,-1980(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP2_STALL);
23003a08:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
23003a0a:	84f6a223          	sw	a5,-1980(a3)
                break;
23003a0e:	bfcd                	j	23003a00 <USB_Clr_EPx_STALL+0x30>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003a10:	8486a703          	lw	a4,-1976(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP3_STALL);
23003a14:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
23003a16:	84f6a423          	sw	a5,-1976(a3)
                break;
23003a1a:	b7dd                	j	23003a00 <USB_Clr_EPx_STALL+0x30>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003a1c:	84c6a703          	lw	a4,-1972(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP4_STALL);
23003a20:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
23003a22:	84f6a623          	sw	a5,-1972(a3)
                break;
23003a26:	bfe9                	j	23003a00 <USB_Clr_EPx_STALL+0x30>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003a28:	8506a703          	lw	a4,-1968(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP5_STALL);
23003a2c:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
23003a2e:	84f6a823          	sw	a5,-1968(a3)
                break;
23003a32:	b7f9                	j	23003a00 <USB_Clr_EPx_STALL+0x30>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003a34:	8546a703          	lw	a4,-1964(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP6_STALL);
23003a38:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
23003a3a:	84f6aa23          	sw	a5,-1964(a3)
                break;
23003a3e:	b7c9                	j	23003a00 <USB_Clr_EPx_STALL+0x30>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003a40:	8586a703          	lw	a4,-1960(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP7_STALL);
23003a44:	8ff9                	and	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
23003a46:	84f6ac23          	sw	a5,-1960(a3)
                break;
23003a4a:	bf5d                	j	23003a00 <USB_Clr_EPx_STALL+0x30>

23003a4c <USB_Set_EPx_Busy>:

BL_Err_Type USB_Set_EPx_Busy(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
23003a4c:	ed01                	bnez	a0,23003a64 <USB_Set_EPx_Busy+0x18>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
23003a4e:	4000e737          	lui	a4,0x4000e
23003a52:	80072783          	lw	a5,-2048(a4) # 4000d800 <__ram_load_addr+0x1d0008dc>
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_NACK_IN);
        tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_USB_EP0_SW_NACK_OUT);
23003a56:	060006b7          	lui	a3,0x6000
23003a5a:	8fd5                	or	a5,a5,a3
        BL_WR_REG(USB_BASE,USB_CONFIG,tmpVal);
23003a5c:	80f72023          	sw	a5,-2048(a4)
                break;
        }
    }
    
    return SUCCESS;
}
23003a60:	4501                	li	a0,0
23003a62:	8082                	ret
        switch(epId){
23003a64:	157d                	addi	a0,a0,-1
23003a66:	0ff57513          	andi	a0,a0,255
23003a6a:	4799                	li	a5,6
23003a6c:	fea7eae3          	bltu	a5,a0,23003a60 <USB_Set_EPx_Busy+0x14>
23003a70:	230067b7          	lui	a5,0x23006
23003a74:	1c078793          	addi	a5,a5,448 # 230061c0 <uartAddr+0x94>
23003a78:	050a                	slli	a0,a0,0x2
23003a7a:	953e                	add	a0,a0,a5
23003a7c:	4118                	lw	a4,0(a0)
23003a7e:	77c1                	lui	a5,0xffff0
23003a80:	17fd                	addi	a5,a5,-1
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003a82:	4000e6b7          	lui	a3,0x4000e
        switch(epId){
23003a86:	8702                	jr	a4
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
23003a88:	8406a703          	lw	a4,-1984(a3) # 4000d840 <__ram_load_addr+0x1d00091c>
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP1_STALL);
23003a8c:	8ff9                	and	a5,a5,a4
23003a8e:	00020737          	lui	a4,0x20
23003a92:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
23003a94:	84f6a023          	sw	a5,-1984(a3)
                break;
23003a98:	b7e1                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
23003a9a:	8446a703          	lw	a4,-1980(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP2_STALL);
23003a9e:	8ff9                	and	a5,a5,a4
23003aa0:	00020737          	lui	a4,0x20
23003aa4:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
23003aa6:	84f6a223          	sw	a5,-1980(a3)
                break;
23003aaa:	bf5d                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003aac:	8486a703          	lw	a4,-1976(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP3_STALL);
23003ab0:	8ff9                	and	a5,a5,a4
23003ab2:	00020737          	lui	a4,0x20
23003ab6:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
23003ab8:	84f6a423          	sw	a5,-1976(a3)
                break;
23003abc:	b755                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003abe:	84c6a703          	lw	a4,-1972(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP4_STALL);
23003ac2:	8ff9                	and	a5,a5,a4
23003ac4:	00020737          	lui	a4,0x20
23003ac8:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
23003aca:	84f6a623          	sw	a5,-1972(a3)
                break;
23003ace:	bf49                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003ad0:	8506a703          	lw	a4,-1968(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP5_STALL);
23003ad4:	8ff9                	and	a5,a5,a4
23003ad6:	00020737          	lui	a4,0x20
23003ada:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
23003adc:	84f6a823          	sw	a5,-1968(a3)
                break;
23003ae0:	b741                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003ae2:	8546a703          	lw	a4,-1964(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP6_STALL);
23003ae6:	8ff9                	and	a5,a5,a4
23003ae8:	00020737          	lui	a4,0x20
23003aec:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
23003aee:	84f6aa23          	sw	a5,-1964(a3)
                break;
23003af2:	b7bd                	j	23003a60 <USB_Set_EPx_Busy+0x14>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003af4:	8586a703          	lw	a4,-1960(a3)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_CR_EP7_STALL);
23003af8:	8ff9                	and	a5,a5,a4
23003afa:	00020737          	lui	a4,0x20
23003afe:	8fd9                	or	a5,a5,a4
                BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
23003b00:	84f6ac23          	sw	a5,-1960(a3)
                break;
23003b04:	bfb1                	j	23003a60 <USB_Set_EPx_Busy+0x14>

23003b06 <USB_Set_EPx_Status>:

BL_Err_Type USB_Set_EPx_Status(USB_EP_ID epId,USB_EP_STATUS_Type sts)
{
23003b06:	1141                	addi	sp,sp,-16
23003b08:	c606                	sw	ra,12(sp)
    switch(sts){
23003b0a:	4785                	li	a5,1
23003b0c:	02f58063          	beq	a1,a5,23003b2c <USB_Set_EPx_Status+0x26>
23003b10:	c999                	beqz	a1,23003b26 <USB_Set_EPx_Status+0x20>
23003b12:	4789                	li	a5,2
23003b14:	00f58e63          	beq	a1,a5,23003b30 <USB_Set_EPx_Status+0x2a>
23003b18:	478d                	li	a5,3
23003b1a:	00f58d63          	beq	a1,a5,23003b34 <USB_Set_EPx_Status+0x2e>
        default :
            break;
    }
    
    return SUCCESS;
}
23003b1e:	40b2                	lw	ra,12(sp)
23003b20:	4501                	li	a0,0
23003b22:	0141                	addi	sp,sp,16
23003b24:	8082                	ret
            USB_Set_EPx_Rdy(epId);
23003b26:	cd5ff0ef          	jal	ra,230037fa <USB_Set_EPx_Rdy>
            break;
23003b2a:	bfd5                	j	23003b1e <USB_Set_EPx_Status+0x18>
            USB_Set_EPx_Busy(epId);
23003b2c:	3705                	jal	23003a4c <USB_Set_EPx_Busy>
            break;
23003b2e:	bfc5                	j	23003b1e <USB_Set_EPx_Status+0x18>
            USB_Set_EPx_STALL(epId);
23003b30:	3519                	jal	23003936 <USB_Set_EPx_STALL>
            break;
23003b32:	b7f5                	j	23003b1e <USB_Set_EPx_Status+0x18>
            USB_Clr_EPx_STALL(epId);
23003b34:	3d71                	jal	230039d0 <USB_Clr_EPx_STALL>
            break;
23003b36:	b7e5                	j	23003b1e <USB_Set_EPx_Status+0x18>

23003b38 <USB_Get_EPx_Status>:

USB_EP_STATUS_Type USB_Get_EPx_Status(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;
    
    if(epId == EP_ID0){
23003b38:	e515                	bnez	a0,23003b64 <USB_Get_EPx_Status+0x2c>
        tmpVal = BL_RD_REG(USB_BASE,USB_CONFIG);
23003b3a:	4000e7b7          	lui	a5,0x4000e
23003b3e:	8007a783          	lw	a5,-2048(a5) # 4000d800 <__ram_load_addr+0x1d0008dc>
        switch((tmpVal>>24)&0x7){
23003b42:	4719                	li	a4,6
23003b44:	83e1                	srli	a5,a5,0x18
23003b46:	8b9d                	andi	a5,a5,7
23003b48:	04f76d63          	bltu	a4,a5,23003ba2 <USB_Get_EPx_Status+0x6a>
23003b4c:	23006737          	lui	a4,0x23006
23003b50:	078a                	slli	a5,a5,0x2
23003b52:	1dc70713          	addi	a4,a4,476 # 230061dc <uartAddr+0xb0>
23003b56:	97ba                	add	a5,a5,a4
23003b58:	439c                	lw	a5,0(a5)
23003b5a:	8782                	jr	a5
            case 0:
                return USB_EP_STATUS_ACK;
            case 1:
                return USB_EP_STATUS_STALL;
23003b5c:	4509                	li	a0,2
23003b5e:	8082                	ret
            case 2:
            case 4:
            case 6:
                return USB_EP_STATUS_NACK;
23003b60:	4505                	li	a0,1
23003b62:	8082                	ret
            default :
                break;
        }
    }else{
        switch(epId){
23003b64:	157d                	addi	a0,a0,-1
23003b66:	0ff57513          	andi	a0,a0,255
23003b6a:	4719                	li	a4,6
            case EP_ID7:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
                break;

            default :
                tmpVal = 0;
23003b6c:	4781                	li	a5,0
        switch(epId){
23003b6e:	00a76e63          	bltu	a4,a0,23003b8a <USB_Get_EPx_Status+0x52>
23003b72:	230067b7          	lui	a5,0x23006
23003b76:	1f878793          	addi	a5,a5,504 # 230061f8 <uartAddr+0xcc>
23003b7a:	050a                	slli	a0,a0,0x2
23003b7c:	953e                	add	a0,a0,a5
23003b7e:	411c                	lw	a5,0(a0)
23003b80:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
23003b82:	4000e7b7          	lui	a5,0x4000e
23003b86:	8407a783          	lw	a5,-1984(a5) # 4000d840 <__ram_load_addr+0x1d00091c>
                break;
        }
        switch((tmpVal>>14)&0x3){
23003b8a:	83b9                	srli	a5,a5,0xe
23003b8c:	8b8d                	andi	a5,a5,3
23003b8e:	4705                	li	a4,1
                return USB_EP_STATUS_STALL;
23003b90:	4509                	li	a0,2
        switch((tmpVal>>14)&0x3){
23003b92:	00e78963          	beq	a5,a4,23003ba4 <USB_Get_EPx_Status+0x6c>
                return USB_EP_STATUS_ACK;
23003b96:	4501                	li	a0,0
        switch((tmpVal>>14)&0x3){
23003b98:	c791                	beqz	a5,23003ba4 <USB_Get_EPx_Status+0x6c>
23003b9a:	4709                	li	a4,2
                return USB_EP_STATUS_NACK;
23003b9c:	4505                	li	a0,1
        switch((tmpVal>>14)&0x3){
23003b9e:	00e78363          	beq	a5,a4,23003ba4 <USB_Get_EPx_Status+0x6c>
            default :
                break;
        }
    }
    
    return USB_EP_STATUS_NSTALL;
23003ba2:	450d                	li	a0,3
}
23003ba4:	8082                	ret
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
23003ba6:	4000e7b7          	lui	a5,0x4000e
23003baa:	8447a783          	lw	a5,-1980(a5) # 4000d844 <__ram_load_addr+0x1d000920>
                break;
23003bae:	bff1                	j	23003b8a <USB_Get_EPx_Status+0x52>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003bb0:	4000e7b7          	lui	a5,0x4000e
23003bb4:	8487a783          	lw	a5,-1976(a5) # 4000d848 <__ram_load_addr+0x1d000924>
                break;
23003bb8:	bfc9                	j	23003b8a <USB_Get_EPx_Status+0x52>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003bba:	4000e7b7          	lui	a5,0x4000e
23003bbe:	84c7a783          	lw	a5,-1972(a5) # 4000d84c <__ram_load_addr+0x1d000928>
                break;
23003bc2:	b7e1                	j	23003b8a <USB_Get_EPx_Status+0x52>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003bc4:	4000e7b7          	lui	a5,0x4000e
23003bc8:	8507a783          	lw	a5,-1968(a5) # 4000d850 <__ram_load_addr+0x1d00092c>
                break;
23003bcc:	bf7d                	j	23003b8a <USB_Get_EPx_Status+0x52>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003bce:	4000e7b7          	lui	a5,0x4000e
23003bd2:	8547a783          	lw	a5,-1964(a5) # 4000d854 <__ram_load_addr+0x1d000930>
                break;
23003bd6:	bf55                	j	23003b8a <USB_Get_EPx_Status+0x52>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003bd8:	4000e7b7          	lui	a5,0x4000e
23003bdc:	8587a783          	lw	a5,-1960(a5) # 4000d858 <__ram_load_addr+0x1d000934>
                break;
23003be0:	b76d                	j	23003b8a <USB_Get_EPx_Status+0x52>

23003be2 <USB_IntEn>:

BL_Err_Type USB_IntEn(USB_INT_Type intType,uint8_t enable)
{
    uint32_t tmpVal = 0;
    
    if(USB_INT_ALL==intType){
23003be2:	02000793          	li	a5,32
23003be6:	02f51063          	bne	a0,a5,23003c06 <USB_IntEn+0x24>
        if(enable){
            BL_WR_REG(USB_BASE,USB_INT_EN,USB_INT_TYPE_ALL);
23003bea:	4000e737          	lui	a4,0x4000e
        if(enable){
23003bee:	c981                	beqz	a1,23003bfe <USB_IntEn+0x1c>
            BL_WR_REG(USB_BASE,USB_INT_EN,USB_INT_TYPE_ALL);
23003bf0:	f90007b7          	lui	a5,0xf9000
23003bf4:	17ed                	addi	a5,a5,-5
        }else{
            BL_WR_REG(USB_BASE,USB_INT_EN,~USB_INT_TYPE_ALL);
23003bf6:	82f72023          	sw	a5,-2016(a4) # 4000d820 <__ram_load_addr+0x1d0008fc>
        tmpVal &= ~(1<<intType);
    }
    BL_WR_REG(USB_BASE,USB_INT_EN,tmpVal);
    
    return SUCCESS;
}
23003bfa:	4501                	li	a0,0
23003bfc:	8082                	ret
            BL_WR_REG(USB_BASE,USB_INT_EN,~USB_INT_TYPE_ALL);
23003bfe:	070007b7          	lui	a5,0x7000
23003c02:	0791                	addi	a5,a5,4
23003c04:	bfcd                	j	23003bf6 <USB_IntEn+0x14>
    tmpVal = BL_RD_REG(USB_BASE,USB_INT_EN);
23003c06:	4000e7b7          	lui	a5,0x4000e
23003c0a:	8207a703          	lw	a4,-2016(a5) # 4000d820 <__ram_load_addr+0x1d0008fc>
    if(enable){
23003c0e:	4785                	li	a5,1
23003c10:	00a79533          	sll	a0,a5,a0
23003c14:	c599                	beqz	a1,23003c22 <USB_IntEn+0x40>
        tmpVal |= (1<<intType);
23003c16:	8d59                	or	a0,a0,a4
    BL_WR_REG(USB_BASE,USB_INT_EN,tmpVal);
23003c18:	4000e7b7          	lui	a5,0x4000e
23003c1c:	82a7a023          	sw	a0,-2016(a5) # 4000d820 <__ram_load_addr+0x1d0008fc>
    return SUCCESS;
23003c20:	bfe9                	j	23003bfa <USB_IntEn+0x18>
        tmpVal &= ~(1<<intType);
23003c22:	fff54513          	not	a0,a0
23003c26:	8d79                	and	a0,a0,a4
23003c28:	bfc5                	j	23003c18 <USB_IntEn+0x36>

23003c2a <USB_IntMask>:

BL_Err_Type USB_IntMask(USB_INT_Type intType,BL_Mask_Type intMask)
{
    uint32_t tmpVal = 0;
    
    if(USB_INT_ALL==intType){
23003c2a:	02000793          	li	a5,32
23003c2e:	02f51063          	bne	a0,a5,23003c4e <USB_IntMask+0x24>
        if(intMask!=UNMASK){
            BL_WR_REG(USB_BASE,USB_INT_MASK,USB_INT_TYPE_ALL);
23003c32:	4000e737          	lui	a4,0x4000e
        if(intMask!=UNMASK){
23003c36:	c981                	beqz	a1,23003c46 <USB_IntMask+0x1c>
            BL_WR_REG(USB_BASE,USB_INT_MASK,USB_INT_TYPE_ALL);
23003c38:	f90007b7          	lui	a5,0xf9000
23003c3c:	17ed                	addi	a5,a5,-5
        }else{
            BL_WR_REG(USB_BASE,USB_INT_MASK,~USB_INT_TYPE_ALL);
23003c3e:	82f72423          	sw	a5,-2008(a4) # 4000d828 <__ram_load_addr+0x1d000904>
        tmpVal &= ~(1<<intType);
    }
    BL_WR_REG(USB_BASE,USB_INT_MASK,tmpVal);
    
    return SUCCESS;
}
23003c42:	4501                	li	a0,0
23003c44:	8082                	ret
            BL_WR_REG(USB_BASE,USB_INT_MASK,~USB_INT_TYPE_ALL);
23003c46:	070007b7          	lui	a5,0x7000
23003c4a:	0791                	addi	a5,a5,4
23003c4c:	bfcd                	j	23003c3e <USB_IntMask+0x14>
    tmpVal = BL_RD_REG(USB_BASE,USB_INT_MASK);
23003c4e:	4000e7b7          	lui	a5,0x4000e
23003c52:	8287a703          	lw	a4,-2008(a5) # 4000d828 <__ram_load_addr+0x1d000904>
    if(intMask!=UNMASK){
23003c56:	4785                	li	a5,1
23003c58:	00a79533          	sll	a0,a5,a0
23003c5c:	c599                	beqz	a1,23003c6a <USB_IntMask+0x40>
        tmpVal |= (1<<intType);
23003c5e:	8d59                	or	a0,a0,a4
    BL_WR_REG(USB_BASE,USB_INT_MASK,tmpVal);
23003c60:	4000e7b7          	lui	a5,0x4000e
23003c64:	82a7a423          	sw	a0,-2008(a5) # 4000d828 <__ram_load_addr+0x1d000904>
    return SUCCESS;
23003c68:	bfe9                	j	23003c42 <USB_IntMask+0x18>
        tmpVal &= ~(1<<intType);
23003c6a:	fff54513          	not	a0,a0
23003c6e:	8d79                	and	a0,a0,a4
23003c70:	bfc5                	j	23003c60 <USB_IntMask+0x36>

23003c72 <USB_Get_IntStatus>:

BL_Sts_Type USB_Get_IntStatus(USB_INT_Type intType)
{
    if(USB_INT_ALL==intType){
23003c72:	02000793          	li	a5,32
23003c76:	00f51963          	bne	a0,a5,23003c88 <USB_Get_IntStatus+0x16>
        return BL_RD_REG(USB_BASE,USB_INT_STS)?SET:RESET;
23003c7a:	4000e7b7          	lui	a5,0x4000e
23003c7e:	8247a503          	lw	a0,-2012(a5) # 4000d824 <__ram_load_addr+0x1d000900>
    }
    
    return ((BL_RD_REG(USB_BASE,USB_INT_STS)&(1<<intType)))?SET:RESET;
23003c82:	00a03533          	snez	a0,a0
}
23003c86:	8082                	ret
    return ((BL_RD_REG(USB_BASE,USB_INT_STS)&(1<<intType)))?SET:RESET;
23003c88:	4000e7b7          	lui	a5,0x4000e
23003c8c:	8247a703          	lw	a4,-2012(a5) # 4000d824 <__ram_load_addr+0x1d000900>
23003c90:	4785                	li	a5,1
23003c92:	00a79533          	sll	a0,a5,a0
23003c96:	8d79                	and	a0,a0,a4
23003c98:	b7ed                	j	23003c82 <USB_Get_IntStatus+0x10>

23003c9a <USB_Clr_IntStatus>:

BL_Err_Type USB_Clr_IntStatus(USB_INT_Type intType)
{
    uint32_t tmpVal = 0;
    
    if(USB_INT_ALL==intType){
23003c9a:	02000793          	li	a5,32
        BL_WR_REG(USB_BASE,USB_INT_CLEAR,USB_INT_TYPE_ALL);
23003c9e:	4000e737          	lui	a4,0x4000e
    if(USB_INT_ALL==intType){
23003ca2:	00f51963          	bne	a0,a5,23003cb4 <USB_Clr_IntStatus+0x1a>
        BL_WR_REG(USB_BASE,USB_INT_CLEAR,USB_INT_TYPE_ALL);
23003ca6:	f90007b7          	lui	a5,0xf9000
23003caa:	17ed                	addi	a5,a5,-5
        return SUCCESS;
    }
    
    tmpVal = BL_RD_REG(USB_BASE,USB_INT_CLEAR);
    tmpVal |= (1<<intType);
    BL_WR_REG(USB_BASE,USB_INT_CLEAR,tmpVal);
23003cac:	82f72623          	sw	a5,-2004(a4) # 4000d82c <__ram_load_addr+0x1d000908>

    return SUCCESS;
}
23003cb0:	4501                	li	a0,0
23003cb2:	8082                	ret
    tmpVal = BL_RD_REG(USB_BASE,USB_INT_CLEAR);
23003cb4:	82c72683          	lw	a3,-2004(a4)
    tmpVal |= (1<<intType);
23003cb8:	4785                	li	a5,1
23003cba:	00a797b3          	sll	a5,a5,a0
23003cbe:	8fd5                	or	a5,a5,a3
23003cc0:	b7f5                	j	23003cac <USB_Clr_IntStatus+0x12>

23003cc2 <USB_Set_EPx_Config>:

BL_Err_Type USB_Set_EPx_Config(USB_EP_ID epId,EP_Config_Type * epCfg)
{
    uint32_t tmpVal = 0;

    if(epId == EP_ID0){
23003cc2:	10050563          	beqz	a0,23003dcc <USB_Set_EPx_Config+0x10a>
        return ERROR;
    }
    switch(epId){
23003cc6:	157d                	addi	a0,a0,-1
23003cc8:	0ff57793          	andi	a5,a0,255
23003ccc:	4719                	li	a4,6

        default :
            break;
    }

    return SUCCESS;
23003cce:	4501                	li	a0,0
    switch(epId){
23003cd0:	0ef76f63          	bltu	a4,a5,23003dce <USB_Set_EPx_Config+0x10c>
23003cd4:	23006537          	lui	a0,0x23006
23003cd8:	21450513          	addi	a0,a0,532 # 23006214 <uartAddr+0xe8>
23003cdc:	078a                	slli	a5,a5,0x2
23003cde:	97aa                	add	a5,a5,a0
23003ce0:	4388                	lw	a0,0(a5)
23003ce2:	77c9                	lui	a5,0xffff2
23003ce4:	fff78613          	addi	a2,a5,-1 # ffff1fff <__HeapLimit+0xbdfc5fff>
23003ce8:	0025c703          	lbu	a4,2(a1)
23003cec:	0035c783          	lbu	a5,3(a1)
23003cf0:	0005d683          	lhu	a3,0(a1)
23003cf4:	8502                	jr	a0
            tmpVal = BL_RD_REG(USB_BASE,USB_EP1_CONFIG);
23003cf6:	4000e537          	lui	a0,0x4000e
23003cfa:	84052583          	lw	a1,-1984(a0) # 4000d840 <__ram_load_addr+0x1d00091c>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_TYPE,epCfg->type);
23003cfe:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_DIR,epCfg->dir);
23003d00:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_TYPE,epCfg->type);
23003d02:	8e6d                	and	a2,a2,a1
23003d04:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_DIR,epCfg->dir);
23003d06:	7679                	lui	a2,0xffffe
23003d08:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP1_SIZE,epCfg->EPMaxPacketSize);
23003d0a:	8fd9                	or	a5,a5,a4
23003d0c:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP1_CONFIG,tmpVal);
23003d0e:	84f52023          	sw	a5,-1984(a0)
    return SUCCESS;
23003d12:	4501                	li	a0,0
            break;
23003d14:	8082                	ret
            tmpVal = BL_RD_REG(USB_BASE,USB_EP2_CONFIG);
23003d16:	4000e537          	lui	a0,0x4000e
23003d1a:	84452583          	lw	a1,-1980(a0) # 4000d844 <__ram_load_addr+0x1d000920>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_TYPE,epCfg->type);
23003d1e:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_DIR,epCfg->dir);
23003d20:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_TYPE,epCfg->type);
23003d22:	8e6d                	and	a2,a2,a1
23003d24:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_DIR,epCfg->dir);
23003d26:	7679                	lui	a2,0xffffe
23003d28:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP2_SIZE,epCfg->EPMaxPacketSize);
23003d2a:	8fd9                	or	a5,a5,a4
23003d2c:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP2_CONFIG,tmpVal);
23003d2e:	84f52223          	sw	a5,-1980(a0)
23003d32:	b7c5                	j	23003d12 <USB_Set_EPx_Config+0x50>
            tmpVal = BL_RD_REG(USB_BASE,USB_EP3_CONFIG);
23003d34:	4000e537          	lui	a0,0x4000e
23003d38:	84852583          	lw	a1,-1976(a0) # 4000d848 <__ram_load_addr+0x1d000924>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_TYPE,epCfg->type);
23003d3c:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_DIR,epCfg->dir);
23003d3e:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_TYPE,epCfg->type);
23003d40:	8e6d                	and	a2,a2,a1
23003d42:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_DIR,epCfg->dir);
23003d44:	7679                	lui	a2,0xffffe
23003d46:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP3_SIZE,epCfg->EPMaxPacketSize);
23003d48:	8fd9                	or	a5,a5,a4
23003d4a:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP3_CONFIG,tmpVal);
23003d4c:	84f52423          	sw	a5,-1976(a0)
            break;
23003d50:	b7c9                	j	23003d12 <USB_Set_EPx_Config+0x50>
            tmpVal = BL_RD_REG(USB_BASE,USB_EP4_CONFIG);
23003d52:	4000e537          	lui	a0,0x4000e
23003d56:	84c52583          	lw	a1,-1972(a0) # 4000d84c <__ram_load_addr+0x1d000928>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_TYPE,epCfg->type);
23003d5a:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_DIR,epCfg->dir);
23003d5c:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_TYPE,epCfg->type);
23003d5e:	8e6d                	and	a2,a2,a1
23003d60:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_DIR,epCfg->dir);
23003d62:	7679                	lui	a2,0xffffe
23003d64:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP4_SIZE,epCfg->EPMaxPacketSize);
23003d66:	8fd9                	or	a5,a5,a4
23003d68:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP4_CONFIG,tmpVal);
23003d6a:	84f52623          	sw	a5,-1972(a0)
            break;
23003d6e:	b755                	j	23003d12 <USB_Set_EPx_Config+0x50>
            tmpVal = BL_RD_REG(USB_BASE,USB_EP5_CONFIG);
23003d70:	4000e537          	lui	a0,0x4000e
23003d74:	85052583          	lw	a1,-1968(a0) # 4000d850 <__ram_load_addr+0x1d00092c>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_TYPE,epCfg->type);
23003d78:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_DIR,epCfg->dir);
23003d7a:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_TYPE,epCfg->type);
23003d7c:	8e6d                	and	a2,a2,a1
23003d7e:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_DIR,epCfg->dir);
23003d80:	7679                	lui	a2,0xffffe
23003d82:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP5_SIZE,epCfg->EPMaxPacketSize);
23003d84:	8fd9                	or	a5,a5,a4
23003d86:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP5_CONFIG,tmpVal);
23003d88:	84f52823          	sw	a5,-1968(a0)
            break;
23003d8c:	b759                	j	23003d12 <USB_Set_EPx_Config+0x50>
            tmpVal = BL_RD_REG(USB_BASE,USB_EP6_CONFIG);
23003d8e:	4000e537          	lui	a0,0x4000e
23003d92:	85452583          	lw	a1,-1964(a0) # 4000d854 <__ram_load_addr+0x1d000930>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_TYPE,epCfg->type);
23003d96:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_DIR,epCfg->dir);
23003d98:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_TYPE,epCfg->type);
23003d9a:	8e6d                	and	a2,a2,a1
23003d9c:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_DIR,epCfg->dir);
23003d9e:	7679                	lui	a2,0xffffe
23003da0:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP6_SIZE,epCfg->EPMaxPacketSize);
23003da2:	8fd9                	or	a5,a5,a4
23003da4:	8fd5                	or	a5,a5,a3
            BL_WR_REG(USB_BASE,USB_EP6_CONFIG,tmpVal);
23003da6:	84f52a23          	sw	a5,-1964(a0)
            break;
23003daa:	b7a5                	j	23003d12 <USB_Set_EPx_Config+0x50>
            tmpVal = BL_RD_REG(USB_BASE,USB_EP7_CONFIG);
23003dac:	4000e537          	lui	a0,0x4000e
23003db0:	85852583          	lw	a1,-1960(a0) # 4000d858 <__ram_load_addr+0x1d000934>
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_TYPE,epCfg->type);
23003db4:	07b6                	slli	a5,a5,0xd
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_DIR,epCfg->dir);
23003db6:	072e                	slli	a4,a4,0xb
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_TYPE,epCfg->type);
23003db8:	8e6d                	and	a2,a2,a1
23003dba:	8fd1                	or	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_DIR,epCfg->dir);
23003dbc:	7679                	lui	a2,0xffffe
23003dbe:	8ff1                	and	a5,a5,a2
            tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_EP7_SIZE,epCfg->EPMaxPacketSize);
23003dc0:	8f5d                	or	a4,a4,a5
23003dc2:	00e6e7b3          	or	a5,a3,a4
            BL_WR_REG(USB_BASE,USB_EP7_CONFIG,tmpVal);
23003dc6:	84f52c23          	sw	a5,-1960(a0)
            break;
23003dca:	b7a1                	j	23003d12 <USB_Set_EPx_Config+0x50>
        return ERROR;
23003dcc:	4505                	li	a0,1
}
23003dce:	8082                	ret

23003dd0 <USB_Set_EPx_TX_DMA_Interface_Config>:

BL_Err_Type USB_Set_EPx_TX_DMA_Interface_Config(USB_EP_ID epId,BL_Fun_Type newState)
{
    uint32_t tmpVal = 0;

    if(newState == ENABLE){
23003dd0:	4785                	li	a5,1
23003dd2:	08f59863          	bne	a1,a5,23003e62 <USB_Set_EPx_TX_DMA_Interface_Config+0x92>
        switch(epId){
23003dd6:	479d                	li	a5,7
23003dd8:	02a7e263          	bltu	a5,a0,23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
23003ddc:	230067b7          	lui	a5,0x23006
23003de0:	23078793          	addi	a5,a5,560 # 23006230 <uartAddr+0x104>
23003de4:	050a                	slli	a0,a0,0x2
23003de6:	953e                	add	a0,a0,a5
23003de8:	411c                	lw	a5,0(a0)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP6_DMA_TX_EN);
                BL_WR_REG(USB_BASE,USB_EP6_FIFO_CONFIG,tmpVal);
                break;

            case EP_ID7:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003dea:	4000e737          	lui	a4,0x4000e
        switch(epId){
23003dee:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
23003df0:	90072783          	lw	a5,-1792(a4) # 4000d900 <__ram_load_addr+0x1d0009dc>
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP0_DMA_TX_EN);
23003df4:	0017e793          	ori	a5,a5,1
    }else{
        switch(epId){
            case EP_ID0:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP0_DMA_TX_EN);
                BL_WR_REG(USB_BASE,USB_EP0_FIFO_CONFIG,tmpVal);
23003df8:	90f72023          	sw	a5,-1792(a4)
                break;
        }
    }
    
    return SUCCESS;
}
23003dfc:	4501                	li	a0,0
23003dfe:	8082                	ret
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_CONFIG);
23003e00:	91072783          	lw	a5,-1776(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP1_DMA_TX_EN);
23003e04:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP1_FIFO_CONFIG,tmpVal);
23003e08:	90f72823          	sw	a5,-1776(a4)
                break;
23003e0c:	bfc5                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_CONFIG);
23003e0e:	92072783          	lw	a5,-1760(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP2_DMA_TX_EN);
23003e12:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP2_FIFO_CONFIG,tmpVal);
23003e16:	92f72023          	sw	a5,-1760(a4)
                break;
23003e1a:	b7cd                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_CONFIG);
23003e1c:	93072783          	lw	a5,-1744(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP3_DMA_TX_EN);
23003e20:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP3_FIFO_CONFIG,tmpVal);
23003e24:	92f72823          	sw	a5,-1744(a4)
                break;
23003e28:	bfd1                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_CONFIG);
23003e2a:	94072783          	lw	a5,-1728(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP4_DMA_TX_EN);
23003e2e:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP4_FIFO_CONFIG,tmpVal);
23003e32:	94f72023          	sw	a5,-1728(a4)
                break;
23003e36:	b7d9                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_CONFIG);
23003e38:	95072783          	lw	a5,-1712(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP5_DMA_TX_EN);
23003e3c:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP5_FIFO_CONFIG,tmpVal);
23003e40:	94f72823          	sw	a5,-1712(a4)
                break;
23003e44:	bf65                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_CONFIG);
23003e46:	96072783          	lw	a5,-1696(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP6_DMA_TX_EN);
23003e4a:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP6_FIFO_CONFIG,tmpVal);
23003e4e:	96f72023          	sw	a5,-1696(a4)
                break;
23003e52:	b76d                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003e54:	97072783          	lw	a5,-1680(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP7_DMA_TX_EN);
23003e58:	0017e793          	ori	a5,a5,1
                BL_WR_REG(USB_BASE,USB_EP7_FIFO_CONFIG,tmpVal);
23003e5c:	96f72823          	sw	a5,-1680(a4)
                break;
23003e60:	bf71                	j	23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
        switch(epId){
23003e62:	479d                	li	a5,7
23003e64:	f8a7ece3          	bltu	a5,a0,23003dfc <USB_Set_EPx_TX_DMA_Interface_Config+0x2c>
23003e68:	230067b7          	lui	a5,0x23006
23003e6c:	25078793          	addi	a5,a5,592 # 23006250 <uartAddr+0x124>
23003e70:	050a                	slli	a0,a0,0x2
23003e72:	953e                	add	a0,a0,a5
23003e74:	411c                	lw	a5,0(a0)
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003e76:	4000e737          	lui	a4,0x4000e
        switch(epId){
23003e7a:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
23003e7c:	90072783          	lw	a5,-1792(a4) # 4000d900 <__ram_load_addr+0x1d0009dc>
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP0_DMA_TX_EN);
23003e80:	9bf9                	andi	a5,a5,-2
23003e82:	bf9d                	j	23003df8 <USB_Set_EPx_TX_DMA_Interface_Config+0x28>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_CONFIG);
23003e84:	91072783          	lw	a5,-1776(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP1_DMA_TX_EN);
23003e88:	9bf9                	andi	a5,a5,-2
23003e8a:	bfbd                	j	23003e08 <USB_Set_EPx_TX_DMA_Interface_Config+0x38>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_CONFIG);
23003e8c:	92072783          	lw	a5,-1760(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP2_DMA_TX_EN);
23003e90:	9bf9                	andi	a5,a5,-2
23003e92:	b751                	j	23003e16 <USB_Set_EPx_TX_DMA_Interface_Config+0x46>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_CONFIG);
23003e94:	93072783          	lw	a5,-1744(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP3_DMA_TX_EN);
23003e98:	9bf9                	andi	a5,a5,-2
23003e9a:	b769                	j	23003e24 <USB_Set_EPx_TX_DMA_Interface_Config+0x54>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_CONFIG);
23003e9c:	94072783          	lw	a5,-1728(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP4_DMA_TX_EN);
23003ea0:	9bf9                	andi	a5,a5,-2
23003ea2:	bf41                	j	23003e32 <USB_Set_EPx_TX_DMA_Interface_Config+0x62>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_CONFIG);
23003ea4:	95072783          	lw	a5,-1712(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP5_DMA_TX_EN);
23003ea8:	9bf9                	andi	a5,a5,-2
23003eaa:	bf59                	j	23003e40 <USB_Set_EPx_TX_DMA_Interface_Config+0x70>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_CONFIG);
23003eac:	96072783          	lw	a5,-1696(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP6_DMA_TX_EN);
23003eb0:	9bf9                	andi	a5,a5,-2
23003eb2:	bf71                	j	23003e4e <USB_Set_EPx_TX_DMA_Interface_Config+0x7e>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003eb4:	97072783          	lw	a5,-1680(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP7_DMA_TX_EN);
23003eb8:	9bf9                	andi	a5,a5,-2
23003eba:	b74d                	j	23003e5c <USB_Set_EPx_TX_DMA_Interface_Config+0x8c>

23003ebc <USB_Set_EPx_RX_DMA_Interface_Config>:

BL_Err_Type USB_Set_EPx_RX_DMA_Interface_Config(USB_EP_ID epId,BL_Fun_Type newState)
{
    uint32_t tmpVal = 0;

    if(newState == ENABLE){
23003ebc:	4785                	li	a5,1
23003ebe:	08f59863          	bne	a1,a5,23003f4e <USB_Set_EPx_RX_DMA_Interface_Config+0x92>
        switch(epId){
23003ec2:	479d                	li	a5,7
23003ec4:	02a7e263          	bltu	a5,a0,23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
23003ec8:	230067b7          	lui	a5,0x23006
23003ecc:	27078793          	addi	a5,a5,624 # 23006270 <uartAddr+0x144>
23003ed0:	050a                	slli	a0,a0,0x2
23003ed2:	953e                	add	a0,a0,a5
23003ed4:	411c                	lw	a5,0(a0)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP6_DMA_RX_EN);
                BL_WR_REG(USB_BASE,USB_EP6_FIFO_CONFIG,tmpVal);
                break;

            case EP_ID7:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003ed6:	4000e737          	lui	a4,0x4000e
        switch(epId){
23003eda:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
23003edc:	90072783          	lw	a5,-1792(a4) # 4000d900 <__ram_load_addr+0x1d0009dc>
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP0_DMA_RX_EN);
23003ee0:	0027e793          	ori	a5,a5,2
    }else{
        switch(epId){
            case EP_ID0:
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP0_DMA_RX_EN);
                BL_WR_REG(USB_BASE,USB_EP0_FIFO_CONFIG,tmpVal);
23003ee4:	90f72023          	sw	a5,-1792(a4)
                break;
        }
    }
    
    return SUCCESS;
}
23003ee8:	4501                	li	a0,0
23003eea:	8082                	ret
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_CONFIG);
23003eec:	91072783          	lw	a5,-1776(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP1_DMA_RX_EN);
23003ef0:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP1_FIFO_CONFIG,tmpVal);
23003ef4:	90f72823          	sw	a5,-1776(a4)
                break;
23003ef8:	bfc5                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_CONFIG);
23003efa:	92072783          	lw	a5,-1760(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP2_DMA_RX_EN);
23003efe:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP2_FIFO_CONFIG,tmpVal);
23003f02:	92f72023          	sw	a5,-1760(a4)
                break;
23003f06:	b7cd                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_CONFIG);
23003f08:	93072783          	lw	a5,-1744(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP3_DMA_RX_EN);
23003f0c:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP3_FIFO_CONFIG,tmpVal);
23003f10:	92f72823          	sw	a5,-1744(a4)
                break;
23003f14:	bfd1                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_CONFIG);
23003f16:	94072783          	lw	a5,-1728(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP4_DMA_RX_EN);
23003f1a:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP4_FIFO_CONFIG,tmpVal);
23003f1e:	94f72023          	sw	a5,-1728(a4)
                break;
23003f22:	b7d9                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_CONFIG);
23003f24:	95072783          	lw	a5,-1712(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP5_DMA_RX_EN);
23003f28:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP5_FIFO_CONFIG,tmpVal);
23003f2c:	94f72823          	sw	a5,-1712(a4)
                break;
23003f30:	bf65                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_CONFIG);
23003f32:	96072783          	lw	a5,-1696(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP6_DMA_RX_EN);
23003f36:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP6_FIFO_CONFIG,tmpVal);
23003f3a:	96f72023          	sw	a5,-1696(a4)
                break;
23003f3e:	b76d                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003f40:	97072783          	lw	a5,-1680(a4)
                tmpVal = BL_SET_REG_BIT(tmpVal,USB_EP7_DMA_RX_EN);
23003f44:	0027e793          	ori	a5,a5,2
                BL_WR_REG(USB_BASE,USB_EP7_FIFO_CONFIG,tmpVal);
23003f48:	96f72823          	sw	a5,-1680(a4)
                break;
23003f4c:	bf71                	j	23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
        switch(epId){
23003f4e:	479d                	li	a5,7
23003f50:	f8a7ece3          	bltu	a5,a0,23003ee8 <USB_Set_EPx_RX_DMA_Interface_Config+0x2c>
23003f54:	230067b7          	lui	a5,0x23006
23003f58:	29078793          	addi	a5,a5,656 # 23006290 <uartAddr+0x164>
23003f5c:	050a                	slli	a0,a0,0x2
23003f5e:	953e                	add	a0,a0,a5
23003f60:	411c                	lw	a5,0(a0)
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003f62:	4000e737          	lui	a4,0x4000e
        switch(epId){
23003f66:	8782                	jr	a5
                tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_CONFIG);
23003f68:	90072783          	lw	a5,-1792(a4) # 4000d900 <__ram_load_addr+0x1d0009dc>
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP0_DMA_RX_EN);
23003f6c:	9bf5                	andi	a5,a5,-3
23003f6e:	bf9d                	j	23003ee4 <USB_Set_EPx_RX_DMA_Interface_Config+0x28>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_CONFIG);
23003f70:	91072783          	lw	a5,-1776(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP1_DMA_RX_EN);
23003f74:	9bf5                	andi	a5,a5,-3
23003f76:	bfbd                	j	23003ef4 <USB_Set_EPx_RX_DMA_Interface_Config+0x38>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_CONFIG);
23003f78:	92072783          	lw	a5,-1760(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP2_DMA_RX_EN);
23003f7c:	9bf5                	andi	a5,a5,-3
23003f7e:	b751                	j	23003f02 <USB_Set_EPx_RX_DMA_Interface_Config+0x46>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_CONFIG);
23003f80:	93072783          	lw	a5,-1744(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP3_DMA_RX_EN);
23003f84:	9bf5                	andi	a5,a5,-3
23003f86:	b769                	j	23003f10 <USB_Set_EPx_RX_DMA_Interface_Config+0x54>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_CONFIG);
23003f88:	94072783          	lw	a5,-1728(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP4_DMA_RX_EN);
23003f8c:	9bf5                	andi	a5,a5,-3
23003f8e:	bf41                	j	23003f1e <USB_Set_EPx_RX_DMA_Interface_Config+0x62>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_CONFIG);
23003f90:	95072783          	lw	a5,-1712(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP5_DMA_RX_EN);
23003f94:	9bf5                	andi	a5,a5,-3
23003f96:	bf59                	j	23003f2c <USB_Set_EPx_RX_DMA_Interface_Config+0x70>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_CONFIG);
23003f98:	96072783          	lw	a5,-1696(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP6_DMA_RX_EN);
23003f9c:	9bf5                	andi	a5,a5,-3
23003f9e:	bf71                	j	23003f3a <USB_Set_EPx_RX_DMA_Interface_Config+0x7e>
                tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_CONFIG);
23003fa0:	97072783          	lw	a5,-1680(a4)
                tmpVal = BL_CLR_REG_BIT(tmpVal,USB_EP7_DMA_RX_EN);
23003fa4:	9bf5                	andi	a5,a5,-3
23003fa6:	b74d                	j	23003f48 <USB_Set_EPx_RX_DMA_Interface_Config+0x8c>

23003fa8 <USB_Get_EPx_TX_FIFO_CNT>:

uint16_t USB_Get_EPx_TX_FIFO_CNT(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;

    switch(epId){
23003fa8:	479d                	li	a5,7
23003faa:	06a7e463          	bltu	a5,a0,23004012 <USB_Get_EPx_TX_FIFO_CNT+0x6a>
23003fae:	230067b7          	lui	a5,0x23006
23003fb2:	2b078793          	addi	a5,a5,688 # 230062b0 <uartAddr+0x184>
23003fb6:	050a                	slli	a0,a0,0x2
23003fb8:	953e                	add	a0,a0,a5
23003fba:	411c                	lw	a5,0(a0)
23003fbc:	8782                	jr	a5
        case EP_ID0:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_STATUS);
23003fbe:	4000e7b7          	lui	a5,0x4000e
23003fc2:	9047a503          	lw	a0,-1788(a5) # 4000d904 <__ram_load_addr+0x1d0009e0>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP0_TX_FIFO_CNT);
            break;

        case EP_ID1:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_STATUS);
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP1_TX_FIFO_CNT);
23003fc6:	07f57513          	andi	a0,a0,127
            break;
23003fca:	8082                	ret
            tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_STATUS);
23003fcc:	4000e7b7          	lui	a5,0x4000e
23003fd0:	9147a503          	lw	a0,-1772(a5) # 4000d914 <__ram_load_addr+0x1d0009f0>
23003fd4:	bfcd                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>

        case EP_ID2:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_STATUS);
23003fd6:	4000e7b7          	lui	a5,0x4000e
23003fda:	9247a503          	lw	a0,-1756(a5) # 4000d924 <__ram_load_addr+0x1d000a00>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP2_TX_FIFO_CNT);
23003fde:	b7e5                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        case EP_ID3:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_STATUS);
23003fe0:	4000e7b7          	lui	a5,0x4000e
23003fe4:	9347a503          	lw	a0,-1740(a5) # 4000d934 <__ram_load_addr+0x1d000a10>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP3_TX_FIFO_CNT);
23003fe8:	bff9                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        case EP_ID4:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_STATUS);
23003fea:	4000e7b7          	lui	a5,0x4000e
23003fee:	9447a503          	lw	a0,-1724(a5) # 4000d944 <__ram_load_addr+0x1d000a20>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP4_TX_FIFO_CNT);
23003ff2:	bfd1                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        case EP_ID5:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_STATUS);
23003ff4:	4000e7b7          	lui	a5,0x4000e
23003ff8:	9547a503          	lw	a0,-1708(a5) # 4000d954 <__ram_load_addr+0x1d000a30>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP5_TX_FIFO_CNT);
23003ffc:	b7e9                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        case EP_ID6:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_STATUS);
23003ffe:	4000e7b7          	lui	a5,0x4000e
23004002:	9647a503          	lw	a0,-1692(a5) # 4000d964 <__ram_load_addr+0x1d000a40>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP6_TX_FIFO_CNT);
23004006:	b7c1                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        case EP_ID7:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_STATUS);
23004008:	4000e7b7          	lui	a5,0x4000e
2300400c:	9747a503          	lw	a0,-1676(a5) # 4000d974 <__ram_load_addr+0x1d000a50>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP7_TX_FIFO_CNT);
23004010:	bf5d                	j	23003fc6 <USB_Get_EPx_TX_FIFO_CNT+0x1e>
            break;

        default :
            tmpVal = 0;
23004012:	4501                	li	a0,0
            break;
    }

    return tmpVal;
}
23004014:	8082                	ret

23004016 <USB_Get_EPx_RX_FIFO_CNT>:

uint16_t USB_Get_EPx_RX_FIFO_CNT(USB_EP_ID epId)
{
    uint32_t tmpVal = 0;

    switch(epId){
23004016:	479d                	li	a5,7
23004018:	06a7e563          	bltu	a5,a0,23004082 <USB_Get_EPx_RX_FIFO_CNT+0x6c>
2300401c:	230067b7          	lui	a5,0x23006
23004020:	2d078793          	addi	a5,a5,720 # 230062d0 <uartAddr+0x1a4>
23004024:	050a                	slli	a0,a0,0x2
23004026:	953e                	add	a0,a0,a5
23004028:	411c                	lw	a5,0(a0)
2300402a:	8782                	jr	a5
        case EP_ID0:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP0_FIFO_STATUS);
2300402c:	4000e7b7          	lui	a5,0x4000e
23004030:	9047a503          	lw	a0,-1788(a5) # 4000d904 <__ram_load_addr+0x1d0009e0>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP0_RX_FIFO_CNT);
            break;

        case EP_ID1:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_STATUS);
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP1_RX_FIFO_CNT);
23004034:	8141                	srli	a0,a0,0x10
23004036:	07f57513          	andi	a0,a0,127
            break;
2300403a:	8082                	ret
            tmpVal = BL_RD_REG(USB_BASE,USB_EP1_FIFO_STATUS);
2300403c:	4000e7b7          	lui	a5,0x4000e
23004040:	9147a503          	lw	a0,-1772(a5) # 4000d914 <__ram_load_addr+0x1d0009f0>
23004044:	bfc5                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>

        case EP_ID2:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP2_FIFO_STATUS);
23004046:	4000e7b7          	lui	a5,0x4000e
2300404a:	9247a503          	lw	a0,-1756(a5) # 4000d924 <__ram_load_addr+0x1d000a00>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP2_RX_FIFO_CNT);
2300404e:	b7dd                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        case EP_ID3:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP3_FIFO_STATUS);
23004050:	4000e7b7          	lui	a5,0x4000e
23004054:	9347a503          	lw	a0,-1740(a5) # 4000d934 <__ram_load_addr+0x1d000a10>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP3_RX_FIFO_CNT);
23004058:	bff1                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        case EP_ID4:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP4_FIFO_STATUS);
2300405a:	4000e7b7          	lui	a5,0x4000e
2300405e:	9447a503          	lw	a0,-1724(a5) # 4000d944 <__ram_load_addr+0x1d000a20>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP4_RX_FIFO_CNT);
23004062:	bfc9                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        case EP_ID5:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP5_FIFO_STATUS);
23004064:	4000e7b7          	lui	a5,0x4000e
23004068:	9547a503          	lw	a0,-1708(a5) # 4000d954 <__ram_load_addr+0x1d000a30>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP5_RX_FIFO_CNT);
2300406c:	b7e1                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        case EP_ID6:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP6_FIFO_STATUS);
2300406e:	4000e7b7          	lui	a5,0x4000e
23004072:	9647a503          	lw	a0,-1692(a5) # 4000d964 <__ram_load_addr+0x1d000a40>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP6_RX_FIFO_CNT);
23004076:	bf7d                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        case EP_ID7:
            tmpVal = BL_RD_REG(USB_BASE,USB_EP7_FIFO_STATUS);
23004078:	4000e7b7          	lui	a5,0x4000e
2300407c:	9747a503          	lw	a0,-1676(a5) # 4000d974 <__ram_load_addr+0x1d000a50>
            tmpVal = BL_GET_REG_BITS_VAL(tmpVal,USB_EP7_RX_FIFO_CNT);
23004080:	bf55                	j	23004034 <USB_Get_EPx_RX_FIFO_CNT+0x1e>
            break;

        default :
            tmpVal = 0;
23004082:	4501                	li	a0,0
            break;
    }

    return tmpVal;
}
23004084:	8082                	ret

23004086 <USB_Set_LPM_Default_Response>:

BL_Err_Type USB_Set_LPM_Default_Response(USB_LPM_DEFAULT_RESP_Type defaultResp)
{
    uint32_t tmpVal = 0;
    
    tmpVal = BL_RD_REG(USB_BASE,USB_LPM_CONFIG);
23004086:	4000e7b7          	lui	a5,0x4000e
2300408a:	8047a703          	lw	a4,-2044(a5) # 4000d804 <__ram_load_addr+0x1d0008e0>
    tmpVal = BL_SET_REG_BITS_VAL(tmpVal,USB_CR_LPM_RESP,defaultResp);
2300408e:	050a                	slli	a0,a0,0x2
23004090:	9b4d                	andi	a4,a4,-13
23004092:	8d59                	or	a0,a0,a4
    BL_WR_REG(USB_BASE,USB_LPM_CONFIG,tmpVal);
23004094:	80a7a223          	sw	a0,-2044(a5)
    
    tmpVal = BL_RD_REG(USB_BASE,USB_LPM_CONFIG);
23004098:	8047a703          	lw	a4,-2044(a5)
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_LPM_RESP_UPD);
    BL_WR_REG(USB_BASE,USB_LPM_CONFIG,tmpVal);
    
    return SUCCESS;
}
2300409c:	4501                	li	a0,0
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_LPM_RESP_UPD);
2300409e:	00276713          	ori	a4,a4,2
    BL_WR_REG(USB_BASE,USB_LPM_CONFIG,tmpVal);
230040a2:	80e7a223          	sw	a4,-2044(a5)
}
230040a6:	8082                	ret

230040a8 <USB_LPM_Enable>:

BL_Err_Type USB_LPM_Enable(void)
{
    uint32_t tmpVal = 0;
    
    tmpVal = BL_RD_REG(USB_BASE,USB_LPM_CONFIG);
230040a8:	4000e737          	lui	a4,0x4000e
230040ac:	80472783          	lw	a5,-2044(a4) # 4000d804 <__ram_load_addr+0x1d0008e0>
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_LPM_EN);
    BL_WR_REG(USB_BASE,USB_LPM_CONFIG,tmpVal);
    
    return SUCCESS;
}
230040b0:	4501                	li	a0,0
    tmpVal = BL_SET_REG_BIT(tmpVal,USB_CR_LPM_EN);
230040b2:	0017e793          	ori	a5,a5,1
    BL_WR_REG(USB_BASE,USB_LPM_CONFIG,tmpVal);
230040b6:	80f72223          	sw	a5,-2044(a4)
}
230040ba:	8082                	ret

230040bc <ftdi_notify_handler>:
	return 0;

}
static void ftdi_notify_handler(uint8_t event, void* arg)
{
	switch (event)
230040bc:	4785                	li	a5,1
230040be:	00f50663          	beq	a0,a5,230040ca <ftdi_notify_handler+0xe>
230040c2:	4789                	li	a5,2
230040c4:	02f50163          	beq	a0,a5,230040e6 <ftdi_notify_handler+0x2a>
230040c8:	8082                	ret
	Latency_Timer1 = 0x0010;
230040ca:	42024737          	lui	a4,0x42024
230040ce:	47c1                	li	a5,16
230040d0:	26f70423          	sb	a5,616(a4) # 42024268 <Latency_Timer1>
	Latency_Timer2 = 0x0010;
230040d4:	42024737          	lui	a4,0x42024
230040d8:	26f704a3          	sb	a5,617(a4) # 42024269 <Latency_Timer2>
	sof_tick = 0;
230040dc:	420257b7          	lui	a5,0x42025
230040e0:	4407a623          	sw	zero,1100(a5) # 4202544c <sof_tick>
230040e4:	8082                	ret
	{
		case USB_EVENT_RESET:
			usbd_ftdi_reset();
			break;
		case USB_EVENT_SOF:
			sof_tick++;
230040e6:	420257b7          	lui	a5,0x42025
230040ea:	44c78793          	addi	a5,a5,1100 # 4202544c <sof_tick>
230040ee:	4398                	lw	a4,0(a5)
230040f0:	0705                	addi	a4,a4,1
230040f2:	c398                	sw	a4,0(a5)
			USBD_LOG_DBG("tick: %d\r\n", sof_tick);
		break;
		default:
			break;
	}	
}
230040f4:	8082                	ret

230040f6 <ftdi_vendor_request_handler>:
{
230040f6:	1101                	addi	sp,sp,-32
230040f8:	ce06                	sw	ra,28(sp)
230040fa:	cc22                	sw	s0,24(sp)
	switch (pSetup->bRequest) 
230040fc:	00154703          	lbu	a4,1(a0)
23004100:	4795                	li	a5,5
23004102:	16f70363          	beq	a4,a5,23004268 <ftdi_vendor_request_handler+0x172>
23004106:	06e7e163          	bltu	a5,a4,23004168 <ftdi_vendor_request_handler+0x72>
2300410a:	4689                	li	a3,2
	return 0;
2300410c:	4401                	li	s0,0
	switch (pSetup->bRequest) 
2300410e:	00d70a63          	beq	a4,a3,23004122 <ftdi_vendor_request_handler+0x2c>
23004112:	87aa                	mv	a5,a0
23004114:	00e6ec63          	bltu	a3,a4,2300412c <ftdi_vendor_request_handler+0x36>
23004118:	c709                	beqz	a4,23004122 <ftdi_vendor_request_handler+0x2c>
2300411a:	4685                	li	a3,1
2300411c:	08d70863          	beq	a4,a3,230041ac <ftdi_vendor_request_handler+0xb6>
			return -1;
23004120:	547d                	li	s0,-1
}
23004122:	8522                	mv	a0,s0
23004124:	40f2                	lw	ra,28(sp)
23004126:	4462                	lw	s0,24(sp)
23004128:	6105                	addi	sp,sp,32
2300412a:	8082                	ret
	switch (pSetup->bRequest) 
2300412c:	468d                	li	a3,3
2300412e:	0cd70363          	beq	a4,a3,230041f4 <ftdi_vendor_request_handler+0xfe>
23004132:	4691                	li	a3,4
23004134:	fed716e3          	bne	a4,a3,23004120 <ftdi_vendor_request_handler+0x2a>
		 	if(actual_baudrate != 1200)
23004138:	42024737          	lui	a4,0x42024
2300413c:	26c72503          	lw	a0,620(a4) # 4202426c <actual_baudrate.2664>
23004140:	4b000713          	li	a4,1200
	return 0;
23004144:	4401                	li	s0,0
		 	if(actual_baudrate != 1200)
23004146:	fce50ee3          	beq	a0,a4,23004122 <ftdi_vendor_request_handler+0x2c>
				usbd_ftdi_set_line_coding(actual_baudrate,(uint8_t)pSetup->wValue,(uint8_t)(pSetup->wValue>>8),(uint8_t)(pSetup->wValue>>11));
2300414a:	0037c583          	lbu	a1,3(a5)
2300414e:	0027c703          	lbu	a4,2(a5)
23004152:	05a2                	slli	a1,a1,0x8
23004154:	8dd9                	or	a1,a1,a4
23004156:	00b5d693          	srli	a3,a1,0xb
2300415a:	0085d613          	srli	a2,a1,0x8
2300415e:	0ff5f593          	andi	a1,a1,255
23004162:	fc4fc0ef          	jal	ra,23000926 <usbd_ftdi_set_line_coding>
23004166:	bf75                	j	23004122 <ftdi_vendor_request_handler+0x2c>
	switch (pSetup->bRequest) 
23004168:	47a5                	li	a5,9
2300416a:	10f70463          	beq	a4,a5,23004272 <ftdi_vendor_request_handler+0x17c>
2300416e:	00e7e863          	bltu	a5,a4,2300417e <ftdi_vendor_request_handler+0x88>
23004172:	479d                	li	a5,7
			return -1;
23004174:	547d                	li	s0,-1
	switch (pSetup->bRequest) 
23004176:	fae7e6e3          	bltu	a5,a4,23004122 <ftdi_vendor_request_handler+0x2c>
	return 0;
2300417a:	4401                	li	s0,0
			break;							
2300417c:	b75d                	j	23004122 <ftdi_vendor_request_handler+0x2c>
	switch (pSetup->bRequest) 
2300417e:	47ad                	li	a5,11
	return 0;
23004180:	4401                	li	s0,0
	switch (pSetup->bRequest) 
23004182:	faf700e3          	beq	a4,a5,23004122 <ftdi_vendor_request_handler+0x2c>
23004186:	10f76763          	bltu	a4,a5,23004294 <ftdi_vendor_request_handler+0x19e>
2300418a:	09000793          	li	a5,144
			return -1;
2300418e:	547d                	li	s0,-1
	switch (pSetup->bRequest) 
23004190:	f8f719e3          	bne	a4,a5,23004122 <ftdi_vendor_request_handler+0x2c>
			*data = (uint8_t*)&ftdi_eeprom_info[pSetup->wIndexL];
23004194:	00454783          	lbu	a5,4(a0)
23004198:	23006737          	lui	a4,0x23006
2300419c:	b0470713          	addi	a4,a4,-1276 # 23005b04 <ftdi_eeprom_info>
230041a0:	0786                	slli	a5,a5,0x1
230041a2:	97ba                	add	a5,a5,a4
			*data = (uint8_t*)&ftdi_eeprom_info[2];
230041a4:	c19c                	sw	a5,0(a1)
			*len = 2;
230041a6:	4789                	li	a5,2
			*len = 1;
230041a8:	c21c                	sw	a5,0(a2)
230041aa:	bfc1                	j	2300417a <ftdi_vendor_request_handler+0x84>
			if(pSetup->wValue == SIO_SET_DTR_HIGH)
230041ac:	00354783          	lbu	a5,3(a0)
230041b0:	00254703          	lbu	a4,2(a0)
				usbd_ftdi_set_dtr(true);
230041b4:	4505                	li	a0,1
			if(pSetup->wValue == SIO_SET_DTR_HIGH)
230041b6:	07a2                	slli	a5,a5,0x8
230041b8:	8fd9                	or	a5,a5,a4
230041ba:	10100713          	li	a4,257
230041be:	00e78763          	beq	a5,a4,230041cc <ftdi_vendor_request_handler+0xd6>
			else if(pSetup->wValue == SIO_SET_DTR_LOW)
230041c2:	10000713          	li	a4,256
230041c6:	00e79663          	bne	a5,a4,230041d2 <ftdi_vendor_request_handler+0xdc>
				usbd_ftdi_set_dtr(false);
230041ca:	4501                	li	a0,0
230041cc:	f5cfc0ef          	jal	ra,23000928 <usbd_ftdi_set_dtr>
230041d0:	b76d                	j	2300417a <ftdi_vendor_request_handler+0x84>
			else if(pSetup->wValue == SIO_SET_RTS_HIGH)
230041d2:	20200713          	li	a4,514
230041d6:	00e79663          	bne	a5,a4,230041e2 <ftdi_vendor_request_handler+0xec>
				usbd_ftdi_set_rts(true);
230041da:	4505                	li	a0,1
230041dc:	f52fc0ef          	jal	ra,2300092e <usbd_ftdi_set_rts>
230041e0:	bf69                	j	2300417a <ftdi_vendor_request_handler+0x84>
			else if(pSetup->wValue == SIO_SET_RTS_LOW)
230041e2:	20000713          	li	a4,512
	return 0;
230041e6:	4401                	li	s0,0
			else if(pSetup->wValue == SIO_SET_RTS_LOW)
230041e8:	f2e79de3          	bne	a5,a4,23004122 <ftdi_vendor_request_handler+0x2c>
				usbd_ftdi_set_rts(false);
230041ec:	4501                	li	a0,0
230041ee:	f40fc0ef          	jal	ra,2300092e <usbd_ftdi_set_rts>
230041f2:	bf05                	j	23004122 <ftdi_vendor_request_handler+0x2c>
			ftdi_set_baudrate(pSetup->wValue|(baudrate_high<<16),&actual_baudrate);	
230041f4:	00554703          	lbu	a4,5(a0)
230041f8:	00354783          	lbu	a5,3(a0)
230041fc:	00254683          	lbu	a3,2(a0)
23004200:	0742                	slli	a4,a4,0x10
23004202:	07a2                	slli	a5,a5,0x8
23004204:	8fd5                	or	a5,a5,a3
23004206:	8fd9                	or	a5,a5,a4
	uint8_t frac[] = {0, 8, 4, 2, 6, 10, 12, 14};
23004208:	02041737          	lui	a4,0x2041
2300420c:	80070713          	addi	a4,a4,-2048 # 2040800 <HeapSize+0x203f800>
23004210:	c43a                	sw	a4,8(sp)
23004212:	0e0c1737          	lui	a4,0xe0c1
23004216:	a0670713          	addi	a4,a4,-1530 # e0c0a06 <HeapSize+0xe0bfa06>
2300421a:	c63a                	sw	a4,12(sp)
 	divisor |= frac[(itdf_divisor >> 14) & 0x07];
2300421c:	0814                	addi	a3,sp,16
2300421e:	00e7d713          	srli	a4,a5,0xe
23004222:	8b1d                	andi	a4,a4,7
23004224:	9736                	add	a4,a4,a3
	if(itdf_divisor == 0x01)
23004226:	4685                	li	a3,1
 	divisor |= frac[(itdf_divisor >> 14) & 0x07];
23004228:	ff874703          	lbu	a4,-8(a4)
	if(itdf_divisor == 0x01)
2300422c:	02d78463          	beq	a5,a3,23004254 <ftdi_vendor_request_handler+0x15e>
	else if(itdf_divisor == 0x00)
23004230:	c79d                	beqz	a5,2300425e <ftdi_vendor_request_handler+0x168>
 	divisor <<= 4;
23004232:	000406b7          	lui	a3,0x40
23004236:	0792                	slli	a5,a5,0x4
23004238:	16c1                	addi	a3,a3,-16
2300423a:	8ff5                	and	a5,a5,a3
 	divisor |= frac[(itdf_divisor >> 14) & 0x07];
2300423c:	8f5d                	or	a4,a4,a5
		baudrate = FTDI_USB_CLK / divisor;
2300423e:	02dc77b7          	lui	a5,0x2dc7
23004242:	c0078793          	addi	a5,a5,-1024 # 2dc6c00 <HeapSize+0x2dc5c00>
23004246:	02e7c7b3          	div	a5,a5,a4
		*actual_baudrate = baudrate;
2300424a:	42024737          	lui	a4,0x42024
2300424e:	26f72623          	sw	a5,620(a4) # 4202426c <actual_baudrate.2664>
23004252:	b725                	j	2300417a <ftdi_vendor_request_handler+0x84>
		baudrate = 2000000;
23004254:	001e87b7          	lui	a5,0x1e8
23004258:	48078793          	addi	a5,a5,1152 # 1e8480 <HeapSize+0x1e7480>
2300425c:	b7fd                	j	2300424a <ftdi_vendor_request_handler+0x154>
		baudrate = 3000000;
2300425e:	002dc7b7          	lui	a5,0x2dc
23004262:	6c078793          	addi	a5,a5,1728 # 2dc6c0 <HeapSize+0x2db6c0>
23004266:	b7d5                	j	2300424a <ftdi_vendor_request_handler+0x154>
			*data = (uint8_t*)&ftdi_eeprom_info[2];
23004268:	230067b7          	lui	a5,0x23006
2300426c:	b0878793          	addi	a5,a5,-1272 # 23005b08 <ftdi_eeprom_info+0x4>
23004270:	bf15                	j	230041a4 <ftdi_vendor_request_handler+0xae>
			if(pSetup->wIndexL == 1)
23004272:	00454683          	lbu	a3,4(a0)
23004276:	4705                	li	a4,1
23004278:	00254783          	lbu	a5,2(a0)
2300427c:	00e69763          	bne	a3,a4,2300428a <ftdi_vendor_request_handler+0x194>
				Latency_Timer1 = pSetup->wValueL;
23004280:	42024737          	lui	a4,0x42024
23004284:	26f70423          	sb	a5,616(a4) # 42024268 <Latency_Timer1>
23004288:	bdcd                	j	2300417a <ftdi_vendor_request_handler+0x84>
				Latency_Timer2 = pSetup->wValueL;
2300428a:	42024737          	lui	a4,0x42024
2300428e:	26f704a3          	sb	a5,617(a4) # 42024269 <Latency_Timer2>
23004292:	b5e5                	j	2300417a <ftdi_vendor_request_handler+0x84>
			if(pSetup->wIndexL == 1)
23004294:	00454703          	lbu	a4,4(a0)
23004298:	4785                	li	a5,1
2300429a:	00f70963          	beq	a4,a5,230042ac <ftdi_vendor_request_handler+0x1b6>
				*data = &Latency_Timer2;
2300429e:	420247b7          	lui	a5,0x42024
230042a2:	26978793          	addi	a5,a5,617 # 42024269 <Latency_Timer2>
230042a6:	c19c                	sw	a5,0(a1)
			*len = 1;
230042a8:	4785                	li	a5,1
230042aa:	bdfd                	j	230041a8 <ftdi_vendor_request_handler+0xb2>
				*data = &Latency_Timer1;
230042ac:	420247b7          	lui	a5,0x42024
230042b0:	26878793          	addi	a5,a5,616 # 42024268 <Latency_Timer1>
230042b4:	bfcd                	j	230042a6 <ftdi_vendor_request_handler+0x1b0>

230042b6 <usbd_ftdi_add_interface>:

void usbd_ftdi_add_interface(usbd_class_t *class, usbd_interface_t *intf)
{
	static usbd_class_t *last_class = NULL;

	if(last_class != class)
230042b6:	420257b7          	lui	a5,0x42025
230042ba:	44878793          	addi	a5,a5,1096 # 42025448 <last_class.2713>
{
230042be:	1101                	addi	sp,sp,-32
	if(last_class != class)
230042c0:	4398                	lw	a4,0(a5)
{
230042c2:	cc22                	sw	s0,24(sp)
230042c4:	ce06                	sw	ra,28(sp)
230042c6:	842a                	mv	s0,a0
	if(last_class != class)
230042c8:	00a70763          	beq	a4,a0,230042d6 <usbd_ftdi_add_interface+0x20>
230042cc:	c62e                	sw	a1,12(sp)
	{
		last_class = class;		
230042ce:	c388                	sw	a0,0(a5)
		usbd_class_register(class);
230042d0:	7ac000ef          	jal	ra,23004a7c <usbd_class_register>
230042d4:	45b2                	lw	a1,12(sp)
	}

	intf->class_handler = NULL;
	intf->custom_handler = NULL;
	intf->vendor_handler = ftdi_vendor_request_handler;
230042d6:	230047b7          	lui	a5,0x23004
230042da:	0f678793          	addi	a5,a5,246 # 230040f6 <ftdi_vendor_request_handler>
230042de:	c59c                	sw	a5,8(a1)
	intf->notify_handler = ftdi_notify_handler;
230042e0:	230047b7          	lui	a5,0x23004
230042e4:	0bc78793          	addi	a5,a5,188 # 230040bc <ftdi_notify_handler>
	usbd_class_add_interface(class,intf);
230042e8:	8522                	mv	a0,s0
}
230042ea:	4462                	lw	s0,24(sp)
230042ec:	40f2                	lw	ra,28(sp)
	intf->class_handler = NULL;
230042ee:	0005a223          	sw	zero,4(a1)
	intf->custom_handler = NULL;
230042f2:	0005a623          	sw	zero,12(a1)
	intf->notify_handler = ftdi_notify_handler;
230042f6:	c99c                	sw	a5,16(a1)
}
230042f8:	6105                	addi	sp,sp,32
	usbd_class_add_interface(class,intf);
230042fa:	79e0006f          	j	23004a98 <usbd_class_add_interface>

230042fe <usbd_set_endpoint>:
 * @param [in]  ep_desc Endpoint descriptor byte array
 *
 * @return true if successfully configured and enabled
 */
static bool usbd_set_endpoint(const struct usb_endpoint_descriptor *ep_desc)
{
230042fe:	1101                	addi	sp,sp,-32
23004300:	ce06                	sw	ra,28(sp)
	struct usbd_endpoint_cfg ep_cfg;

	ep_cfg.ep_addr = ep_desc->bEndpointAddress;
23004302:	00254583          	lbu	a1,2(a0)
	ep_cfg.ep_mps = ep_desc->wMaxPacketSize;
	ep_cfg.ep_type = ep_desc->bmAttributes & USBD_EP_TYPE_MASK;
23004306:	00354603          	lbu	a2,3(a0)
	ep_cfg.ep_addr = ep_desc->bEndpointAddress;
2300430a:	00b10423          	sb	a1,8(sp)
	ep_cfg.ep_mps = ep_desc->wMaxPacketSize;
2300430e:	00554683          	lbu	a3,5(a0)
23004312:	00454783          	lbu	a5,4(a0)

	USBD_LOG("Open endpoint:0x%x type:%u mps:%u\r\n",
23004316:	23006537          	lui	a0,0x23006
	ep_cfg.ep_mps = ep_desc->wMaxPacketSize;
2300431a:	06a2                	slli	a3,a3,0x8
2300431c:	8edd                	or	a3,a3,a5
	ep_cfg.ep_type = ep_desc->bmAttributes & USBD_EP_TYPE_MASK;
2300431e:	8a0d                	andi	a2,a2,3
	USBD_LOG("Open endpoint:0x%x type:%u mps:%u\r\n",
23004320:	4d450513          	addi	a0,a0,1236 # 230064d4 <uartAddr+0x3a8>
	ep_cfg.ep_mps = ep_desc->wMaxPacketSize;
23004324:	00d11523          	sh	a3,10(sp)
	ep_cfg.ep_type = ep_desc->bmAttributes & USBD_EP_TYPE_MASK;
23004328:	00c10623          	sb	a2,12(sp)
	USBD_LOG("Open endpoint:0x%x type:%u mps:%u\r\n",
2300432c:	dc7fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
			 ep_cfg.ep_addr, ep_cfg.ep_type, ep_cfg.ep_mps);

	usbd_ep_open(&ep_cfg);
23004330:	0028                	addi	a0,sp,8
23004332:	96bfc0ef          	jal	ra,23000c9c <usbd_ep_open>
	usbd_core_cfg.configured = true;

	return true;
}
23004336:	40f2                	lw	ra,28(sp)
	usbd_core_cfg.configured = true;
23004338:	420247b7          	lui	a5,0x42024
2300433c:	4705                	li	a4,1
2300433e:	78e78aa3          	sb	a4,1941(a5) # 42024795 <usbd_core_cfg+0x15d>
}
23004342:	4505                	li	a0,1
23004344:	6105                	addi	sp,sp,32
23004346:	8082                	ret

23004348 <usbd_send_to_host.isra.2>:
/**
 * @brief send data or status to host
 *
 * @return N/A
 */
static void usbd_send_to_host(uint16_t len)
23004348:	1101                	addi	sp,sp,-32
2300434a:	cc22                	sw	s0,24(sp)
{
	uint32_t chunk = 0U;
	if (usbd_core_cfg.zlp_flag == false)
2300434c:	42024437          	lui	s0,0x42024
23004350:	63840413          	addi	s0,s0,1592 # 42024638 <usbd_core_cfg>
23004354:	01444783          	lbu	a5,20(s0)
static void usbd_send_to_host(uint16_t len)
23004358:	ce06                	sw	ra,28(sp)
	uint32_t chunk = 0U;
2300435a:	c602                	sw	zero,12(sp)
	if (usbd_core_cfg.zlp_flag == false)
2300435c:	ef8d                	bnez	a5,23004396 <usbd_send_to_host.isra.2+0x4e>
	{
		chunk = usbd_core_cfg.ep0_data_buf_residue;
2300435e:	4450                	lw	a2,12(s0)
		usbd_ep_write(USB_CONTROL_IN_EP0, usbd_core_cfg.ep0_data_buf,
23004360:	440c                	lw	a1,8(s0)
23004362:	0074                	addi	a3,sp,12
23004364:	08000513          	li	a0,128
		chunk = usbd_core_cfg.ep0_data_buf_residue;
23004368:	c632                	sw	a2,12(sp)
		usbd_ep_write(USB_CONTROL_IN_EP0, usbd_core_cfg.ep0_data_buf,
2300436a:	98dfc0ef          	jal	ra,23000cf6 <usbd_ep_write>
						usbd_core_cfg.ep0_data_buf_residue, &chunk);
		usbd_core_cfg.ep0_data_buf += chunk;
		usbd_core_cfg.ep0_data_buf_residue -= chunk;
2300436e:	445c                	lw	a5,12(s0)
		usbd_core_cfg.ep0_data_buf += chunk;
23004370:	4732                	lw	a4,12(sp)
23004372:	4414                	lw	a3,8(s0)
23004374:	96ba                	add	a3,a3,a4
		usbd_core_cfg.ep0_data_buf_residue -= chunk;
23004376:	40e78733          	sub	a4,a5,a4
		 * Set ZLP flag when host asks for a bigger length and the
		 * last chunk is wMaxPacketSize long, to indicate the last
		 * packet.
		 */
		/* Send less data as requested during the Setup stage */
		if ((!usbd_core_cfg.ep0_data_buf_residue) && !(usbd_core_cfg.ep0_data_buf_len % USB_CTRL_EP_MPS)) 
2300437a:	481c                	lw	a5,16(s0)
		usbd_core_cfg.ep0_data_buf += chunk;
2300437c:	c414                	sw	a3,8(s0)
		usbd_core_cfg.ep0_data_buf_residue -= chunk;
2300437e:	c458                	sw	a4,12(s0)
		if ((!usbd_core_cfg.ep0_data_buf_residue) && !(usbd_core_cfg.ep0_data_buf_len % USB_CTRL_EP_MPS)) 
23004380:	03f7f793          	andi	a5,a5,63
23004384:	8fd9                	or	a5,a5,a4
23004386:	e781                	bnez	a5,2300438e <usbd_send_to_host.isra.2+0x46>
		{
				/* Transfers a zero-length packet */
				// USBD_LOG("ZLP, requested %u , length %u ",
				// 	len, usb_dev.ep0_data_buf_len);
				usbd_core_cfg.zlp_flag = true;
23004388:	4785                	li	a5,1
2300438a:	00f40a23          	sb	a5,20(s0)
	else
	{
		usbd_core_cfg.zlp_flag = false;
		usbd_ep_write(USB_CONTROL_IN_EP0, NULL, 0, NULL);
	}
}
2300438e:	40f2                	lw	ra,28(sp)
23004390:	4462                	lw	s0,24(sp)
23004392:	6105                	addi	sp,sp,32
23004394:	8082                	ret
		usbd_ep_write(USB_CONTROL_IN_EP0, NULL, 0, NULL);
23004396:	4681                	li	a3,0
23004398:	4601                	li	a2,0
2300439a:	4581                	li	a1,0
2300439c:	08000513          	li	a0,128
		usbd_core_cfg.zlp_flag = false;
230043a0:	00040a23          	sb	zero,20(s0)
		usbd_ep_write(USB_CONTROL_IN_EP0, NULL, 0, NULL);
230043a4:	953fc0ef          	jal	ra,23000cf6 <usbd_ep_write>
230043a8:	b7dd                	j	2300438e <usbd_send_to_host.isra.2+0x46>

230043aa <usbd_print_setup.constprop.14>:
	USBD_LOG_ERR("Setup: "
230043aa:	420245b7          	lui	a1,0x42024
230043ae:	63858593          	addi	a1,a1,1592 # 42024638 <usbd_core_cfg>
230043b2:	0065d783          	lhu	a5,6(a1)
230043b6:	0045d703          	lhu	a4,4(a1)
230043ba:	0025d683          	lhu	a3,2(a1)
230043be:	0015c603          	lbu	a2,1(a1)
230043c2:	0005c583          	lbu	a1,0(a1)
230043c6:	23006537          	lui	a0,0x23006
230043ca:	47450513          	addi	a0,a0,1140 # 23006474 <uartAddr+0x348>
230043ce:	d25fc06f          	j	230010f2 <bflb_platform_printf>

230043d2 <usbd_event_notify_handler>:
		}			
	}
}

void usbd_event_notify_handler(uint8_t event, void* arg)
{
230043d2:	7179                	addi	sp,sp,-48
230043d4:	d226                	sw	s1,36(sp)
230043d6:	d606                	sw	ra,44(sp)
230043d8:	d422                	sw	s0,40(sp)
230043da:	d04a                	sw	s2,32(sp)
230043dc:	ce4e                	sw	s3,28(sp)
	switch (event)
230043de:	47c5                	li	a5,17
{
230043e0:	84aa                	mv	s1,a0
	switch (event)
230043e2:	1ea7e463          	bltu	a5,a0,230045ca <usbd_event_notify_handler+0x1f8>
230043e6:	23006737          	lui	a4,0x23006
230043ea:	00251793          	slli	a5,a0,0x2
230043ee:	2f070713          	addi	a4,a4,752 # 230062f0 <uartAddr+0x1c4>
230043f2:	97ba                	add	a5,a5,a4
230043f4:	439c                	lw	a5,0(a5)
230043f6:	842e                	mv	s0,a1
230043f8:	8782                	jr	a5
	{
		case USB_EVENT_RESET:
			usbd_set_address(0);
230043fa:	4501                	li	a0,0
230043fc:	891fc0ef          	jal	ra,23000c8c <usbd_set_address>
	usb_slist_for_each(i,&usbd_class_head)
23004400:	420257b7          	lui	a5,0x42025
23004404:	4587a683          	lw	a3,1112(a5) # 42025458 <usbd_class_head>
23004408:	42024637          	lui	a2,0x42024
2300440c:	63860613          	addi	a2,a2,1592 # 42024638 <usbd_core_cfg>
23004410:	ee91                	bnez	a3,2300442c <usbd_event_notify_handler+0x5a>
	usb_slist_for_each(i,&usbd_class_head)
23004412:	420257b7          	lui	a5,0x42025
23004416:	4587a903          	lw	s2,1112(a5) # 42025458 <usbd_class_head>
2300441a:	04091763          	bnez	s2,23004468 <usbd_event_notify_handler+0x96>
			break;
		default:
			USBD_LOG_ERR("USB unknown event: %d", event);
			break;
	}
}
2300441e:	50b2                	lw	ra,44(sp)
23004420:	5422                	lw	s0,40(sp)
23004422:	5492                	lw	s1,36(sp)
23004424:	5902                	lw	s2,32(sp)
23004426:	49f2                	lw	s3,28(sp)
23004428:	6145                	addi	sp,sp,48
2300442a:	8082                	ret
		usb_slist_for_each(j,&class->intf_list)
2300442c:	468c                	lw	a1,8(a3)
2300442e:	e199                	bnez	a1,23004434 <usbd_event_notify_handler+0x62>
	usb_slist_for_each(i,&usbd_class_head)
23004430:	4294                	lw	a3,0(a3)
23004432:	bff9                	j	23004410 <usbd_event_notify_handler+0x3e>
			usb_slist_for_each(k,&intf->ep_list)
23004434:	4d98                	lw	a4,24(a1)
23004436:	e319                	bnez	a4,2300443c <usbd_event_notify_handler+0x6a>
		usb_slist_for_each(j,&class->intf_list)
23004438:	418c                	lw	a1,0(a1)
2300443a:	bfd5                	j	2300442e <usbd_event_notify_handler+0x5c>
				if(ept->ep_cb)
2300443c:	4708                	lw	a0,8(a4)
2300443e:	c105                	beqz	a0,2300445e <usbd_event_notify_handler+0x8c>
					if(ept->ep_addr & 0x80)
23004440:	00474783          	lbu	a5,4(a4)
23004444:	01879813          	slli	a6,a5,0x18
23004448:	41885813          	srai	a6,a6,0x18
2300444c:	00085b63          	bgez	a6,23004462 <usbd_event_notify_handler+0x90>
						usbd_core_cfg.in_ep_cb[ept->ep_addr & 0x7f] = ept->ep_cb;
23004450:	07f7f793          	andi	a5,a5,127
23004454:	04478793          	addi	a5,a5,68
						usbd_core_cfg.out_ep_cb[ept->ep_addr & 0x7f] = ept->ep_cb;
23004458:	078a                	slli	a5,a5,0x2
2300445a:	97b2                	add	a5,a5,a2
2300445c:	c7c8                	sw	a0,12(a5)
			usb_slist_for_each(k,&intf->ep_list)
2300445e:	4318                	lw	a4,0(a4)
23004460:	bfd9                	j	23004436 <usbd_event_notify_handler+0x64>
						usbd_core_cfg.out_ep_cb[ept->ep_addr & 0x7f] = ept->ep_cb;
23004462:	04c78793          	addi	a5,a5,76
23004466:	bfcd                	j	23004458 <usbd_event_notify_handler+0x86>
		usb_slist_for_each(j,&class->intf_list)
23004468:	00892983          	lw	s3,8(s2)
2300446c:	00099563          	bnez	s3,23004476 <usbd_event_notify_handler+0xa4>
	usb_slist_for_each(i,&usbd_class_head)
23004470:	00092903          	lw	s2,0(s2)
23004474:	b75d                	j	2300441a <usbd_event_notify_handler+0x48>
			if(intf->notify_handler)
23004476:	0109a783          	lw	a5,16(s3)
2300447a:	c781                	beqz	a5,23004482 <usbd_event_notify_handler+0xb0>
				intf->notify_handler(event, arg);
2300447c:	85a2                	mv	a1,s0
2300447e:	8526                	mv	a0,s1
23004480:	9782                	jalr	a5
		usb_slist_for_each(j,&class->intf_list)
23004482:	0009a983          	lw	s3,0(s3)
23004486:	b7dd                	j	2300446c <usbd_event_notify_handler+0x9a>
	if (usbd_ep_read(USB_CONTROL_OUT_EP0, (uint8_t *)setup,
23004488:	42024437          	lui	s0,0x42024
2300448c:	63840593          	addi	a1,s0,1592 # 42024638 <usbd_core_cfg>
23004490:	4681                	li	a3,0
23004492:	4621                	li	a2,8
23004494:	4501                	li	a0,0
23004496:	875fc0ef          	jal	ra,23000d0a <usbd_ep_read>
2300449a:	63840493          	addi	s1,s0,1592
2300449e:	63840413          	addi	s0,s0,1592
230044a2:	00055d63          	bgez	a0,230044bc <usbd_event_notify_handler+0xea>
		USBD_LOG_ERR("Read Setup Packet failed\r\n");
230044a6:	23006537          	lui	a0,0x23006
230044aa:	39850513          	addi	a0,a0,920 # 23006398 <uartAddr+0x26c>
			USBD_LOG_ERR("Request buffer too small\r\n");
230044ae:	c45fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
			usbd_ep_set_stall(USB_CONTROL_IN_EP0);
230044b2:	08000513          	li	a0,128
230044b6:	811fc0ef          	jal	ra,23000cc6 <usbd_ep_set_stall>
			return;
230044ba:	b795                	j	2300441e <usbd_event_notify_handler+0x4c>
	if (setup->wLength > USB_REQUEST_BUFFER_SIZE)
230044bc:	0064d783          	lhu	a5,6(s1)
230044c0:	10000713          	li	a4,256
230044c4:	00f77b63          	bgeu	a4,a5,230044da <usbd_event_notify_handler+0x108>
		if (setup->bmRequestType_b.Dir != USB_REQUEST_DEVICE_TO_HOST)
230044c8:	00048703          	lb	a4,0(s1)
230044cc:	00074763          	bltz	a4,230044da <usbd_event_notify_handler+0x108>
			USBD_LOG_ERR("Request buffer too small\r\n");
230044d0:	23006537          	lui	a0,0x23006
230044d4:	3b450513          	addi	a0,a0,948 # 230063b4 <uartAddr+0x288>
230044d8:	bfd9                	j	230044ae <usbd_event_notify_handler+0xdc>
	usbd_core_cfg.ep0_data_buf_residue = setup->wLength;
230044da:	c45c                	sw	a5,12(s0)
	usbd_core_cfg.ep0_data_buf_len = setup->wLength;
230044dc:	c81c                	sw	a5,16(s0)
	usbd_core_cfg.zlp_flag = false;
230044de:	00040a23          	sb	zero,20(s0)
	if (setup->wLength &&
230044e2:	cf81                	beqz	a5,230044fa <usbd_event_notify_handler+0x128>
230044e4:	00040783          	lb	a5,0(s0)
230044e8:	0007c963          	bltz	a5,230044fa <usbd_event_notify_handler+0x128>
		usbd_ep_read(USB_CONTROL_OUT_EP0,NULL,0,NULL);
230044ec:	4681                	li	a3,0
230044ee:	4601                	li	a2,0
230044f0:	4581                	li	a1,0
230044f2:	4501                	li	a0,0
230044f4:	817fc0ef          	jal	ra,23000d0a <usbd_ep_read>
		return;
230044f8:	b71d                	j	2300441e <usbd_event_notify_handler+0x4c>
	if (!usbd_setup_request_handler(setup, &usbd_core_cfg.ep0_data_buf, &usbd_core_cfg.ep0_data_buf_len))
230044fa:	20c5                	jal	230045da <usbd_setup_request_handler.constprop.4>
230044fc:	e511                	bnez	a0,23004508 <usbd_event_notify_handler+0x136>
		USBD_LOG_ERR("usbd_setup_request_handler failed\r\n");
230044fe:	23006537          	lui	a0,0x23006
23004502:	3d050513          	addi	a0,a0,976 # 230063d0 <uartAddr+0x2a4>
23004506:	b765                	j	230044ae <usbd_event_notify_handler+0xdc>
	usbd_core_cfg.ep0_data_buf_residue = MIN(usbd_core_cfg.ep0_data_buf_len,
23004508:	4818                	lw	a4,16(s0)
2300450a:	00645783          	lhu	a5,6(s0)
2300450e:	00f77363          	bgeu	a4,a5,23004514 <usbd_event_notify_handler+0x142>
23004512:	87ba                	mv	a5,a4
23004514:	c45c                	sw	a5,12(s0)
		usbd_send_to_host(setup->wLength);
23004516:	3d0d                	jal	23004348 <usbd_send_to_host.isra.2>
23004518:	b719                	j	2300441e <usbd_event_notify_handler+0x4c>
	if (usbd_core_cfg.ep0_data_buf_residue != 0 || usbd_core_cfg.zlp_flag == true) 
2300451a:	420247b7          	lui	a5,0x42024
2300451e:	63878793          	addi	a5,a5,1592 # 42024638 <usbd_core_cfg>
23004522:	47d8                	lw	a4,12(a5)
23004524:	fb6d                	bnez	a4,23004516 <usbd_event_notify_handler+0x144>
23004526:	0147c783          	lbu	a5,20(a5)
2300452a:	ee078ae3          	beqz	a5,2300441e <usbd_event_notify_handler+0x4c>
2300452e:	b7e5                	j	23004516 <usbd_event_notify_handler+0x144>
	if (usbd_core_cfg.ep0_data_buf_residue == 0)
23004530:	42024437          	lui	s0,0x42024
23004534:	63840413          	addi	s0,s0,1592 # 42024638 <usbd_core_cfg>
23004538:	4450                	lw	a2,12(s0)
	uint32_t chunk = 0U;
2300453a:	c602                	sw	zero,12(sp)
	if (usbd_core_cfg.ep0_data_buf_residue == 0)
2300453c:	ee09                	bnez	a2,23004556 <usbd_event_notify_handler+0x184>
		if (usbd_ep_read(USB_CONTROL_OUT_EP0,
2300453e:	4681                	li	a3,0
23004540:	4581                	li	a1,0
23004542:	4501                	li	a0,0
23004544:	fc6fc0ef          	jal	ra,23000d0a <usbd_ep_read>
23004548:	ec055be3          	bgez	a0,2300441e <usbd_event_notify_handler+0x4c>
			USBD_LOG_ERR("Read DATA Packet failed\r\n");
2300454c:	23006537          	lui	a0,0x23006
23004550:	3f450513          	addi	a0,a0,1012 # 230063f4 <uartAddr+0x2c8>
23004554:	bfa9                	j	230044ae <usbd_event_notify_handler+0xdc>
	usbd_core_cfg.ep0_data_buf = usbd_core_cfg.req_data;
23004556:	01c40493          	addi	s1,s0,28
	if (usbd_ep_read(USB_CONTROL_OUT_EP0,
2300455a:	0074                	addi	a3,sp,12
2300455c:	85a6                	mv	a1,s1
2300455e:	4501                	li	a0,0
	usbd_core_cfg.ep0_data_buf = usbd_core_cfg.req_data;
23004560:	c404                	sw	s1,8(s0)
	if (usbd_ep_read(USB_CONTROL_OUT_EP0,
23004562:	fa8fc0ef          	jal	ra,23000d0a <usbd_ep_read>
23004566:	fe0543e3          	bltz	a0,2300454c <usbd_event_notify_handler+0x17a>
	usbd_core_cfg.ep0_data_buf += chunk;
2300456a:	46b2                	lw	a3,12(sp)
2300456c:	4418                	lw	a4,8(s0)
	usbd_core_cfg.ep0_data_buf_residue -= chunk;
2300456e:	445c                	lw	a5,12(s0)
	usbd_core_cfg.ep0_data_buf += chunk;
23004570:	9736                	add	a4,a4,a3
	usbd_core_cfg.ep0_data_buf_residue -= chunk;
23004572:	8f95                	sub	a5,a5,a3
	usbd_core_cfg.ep0_data_buf += chunk;
23004574:	c418                	sw	a4,8(s0)
	usbd_core_cfg.ep0_data_buf_residue -= chunk;
23004576:	c45c                	sw	a5,12(s0)
	if (usbd_core_cfg.ep0_data_buf_residue == 0) 
23004578:	eb89                	bnez	a5,2300458a <usbd_event_notify_handler+0x1b8>
		usbd_core_cfg.ep0_data_buf = usbd_core_cfg.req_data;
2300457a:	c404                	sw	s1,8(s0)
		if (!usbd_setup_request_handler(setup, &usbd_core_cfg.ep0_data_buf, &usbd_core_cfg.ep0_data_buf_len))
2300457c:	28b9                	jal	230045da <usbd_setup_request_handler.constprop.4>
2300457e:	fd41                	bnez	a0,23004516 <usbd_event_notify_handler+0x144>
			USBD_LOG_ERR("usbd_setup_request_handler1 failed\r\n");
23004580:	23006537          	lui	a0,0x23006
23004584:	41050513          	addi	a0,a0,1040 # 23006410 <uartAddr+0x2e4>
23004588:	b71d                	j	230044ae <usbd_event_notify_handler+0xdc>
		USBD_LOG_ERR("ep0_data_buf_residue is not zero\r\n");
2300458a:	23006537          	lui	a0,0x23006
2300458e:	43850513          	addi	a0,a0,1080 # 23006438 <uartAddr+0x30c>
23004592:	b61fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
23004596:	b561                	j	2300441e <usbd_event_notify_handler+0x4c>
			usbd_ep_in_handler((uint32_t)arg);
23004598:	0ff5f513          	andi	a0,a1,255
	if(usbd_core_cfg.in_ep_cb[ep & 0x7f])
2300459c:	07f57793          	andi	a5,a0,127
230045a0:	04478793          	addi	a5,a5,68
	if(usbd_core_cfg.out_ep_cb[ep & 0x7f])
230045a4:	00279713          	slli	a4,a5,0x2
230045a8:	420247b7          	lui	a5,0x42024
230045ac:	63878793          	addi	a5,a5,1592 # 42024638 <usbd_core_cfg>
230045b0:	97ba                	add	a5,a5,a4
230045b2:	47dc                	lw	a5,12(a5)
230045b4:	e60785e3          	beqz	a5,2300441e <usbd_event_notify_handler+0x4c>
		usbd_core_cfg.out_ep_cb[ep & 0x7f](ep);
230045b8:	9782                	jalr	a5
230045ba:	b595                	j	2300441e <usbd_event_notify_handler+0x4c>
			usbd_ep_out_handler((uint32_t)arg);
230045bc:	0ff5f513          	andi	a0,a1,255
	if(usbd_core_cfg.out_ep_cb[ep & 0x7f])
230045c0:	07f57793          	andi	a5,a0,127
230045c4:	04c78793          	addi	a5,a5,76
230045c8:	bff1                	j	230045a4 <usbd_event_notify_handler+0x1d2>
			USBD_LOG_ERR("USB unknown event: %d", event);
230045ca:	85aa                	mv	a1,a0
230045cc:	23006537          	lui	a0,0x23006
230045d0:	45c50513          	addi	a0,a0,1116 # 2300645c <uartAddr+0x330>
230045d4:	b1ffc0ef          	jal	ra,230010f2 <bflb_platform_printf>
}
230045d8:	b599                	j	2300441e <usbd_event_notify_handler+0x4c>

230045da <usbd_setup_request_handler.constprop.4>:
static bool usbd_setup_request_handler(struct usb_setup_packet *setup, uint8_t **data, uint32_t *len)
230045da:	7179                	addi	sp,sp,-48
230045dc:	d226                	sw	s1,36(sp)
	uint8_t type = setup->bmRequestType_b.Type;
230045de:	420244b7          	lui	s1,0x42024
static bool usbd_setup_request_handler(struct usb_setup_packet *setup, uint8_t **data, uint32_t *len)
230045e2:	d04a                	sw	s2,32(sp)
	uint8_t type = setup->bmRequestType_b.Type;
230045e4:	63848913          	addi	s2,s1,1592 # 42024638 <usbd_core_cfg>
230045e8:	00092783          	lw	a5,0(s2)
static bool usbd_setup_request_handler(struct usb_setup_packet *setup, uint8_t **data, uint32_t *len)
230045ec:	d422                	sw	s0,40(sp)
230045ee:	d606                	sw	ra,44(sp)
	uint8_t type = setup->bmRequestType_b.Type;
230045f0:	8395                	srli	a5,a5,0x5
static bool usbd_setup_request_handler(struct usb_setup_packet *setup, uint8_t **data, uint32_t *len)
230045f2:	ce4e                	sw	s3,28(sp)
230045f4:	cc52                	sw	s4,24(sp)
230045f6:	ca56                	sw	s5,20(sp)
230045f8:	c85a                	sw	s6,16(sp)
230045fa:	c65e                	sw	s7,12(sp)
230045fc:	c462                	sw	s8,8(sp)
230045fe:	c266                	sw	s9,4(sp)
	uint8_t type = setup->bmRequestType_b.Type;
23004600:	8b8d                	andi	a5,a5,3
	if (type == USB_REQUEST_STANDARD)
23004602:	63848413          	addi	s0,s1,1592
23004606:	34079d63          	bnez	a5,23004960 <usbd_setup_request_handler.constprop.4+0x386>
	if (setup->bmRequestType_b.Recipient != USB_REQUEST_TO_INTERFACE)
2300460a:	00044783          	lbu	a5,0(s0)
2300460e:	4705                	li	a4,1
23004610:	8bfd                	andi	a5,a5,31
23004612:	04e78263          	beq	a5,a4,23004656 <usbd_setup_request_handler.constprop.4+0x7c>
	switch (setup->bmRequestType_b.Recipient)
23004616:	401c                	lw	a5,0(s0)
23004618:	4705                	li	a4,1
2300461a:	8bfd                	andi	a5,a5,31
2300461c:	1ee78663          	beq	a5,a4,23004808 <usbd_setup_request_handler.constprop.4+0x22e>
23004620:	cba5                	beqz	a5,23004690 <usbd_setup_request_handler.constprop.4+0xb6>
23004622:	4689                	li	a3,2
23004624:	28d78c63          	beq	a5,a3,230048bc <usbd_setup_request_handler.constprop.4+0x2e2>
			USBD_LOG_ERR("Handler Error %d\r\n", type);
23004628:	4581                	li	a1,0
			USBD_LOG_ERR("Handler Error %d\r\n", type);
2300462a:	23006537          	lui	a0,0x23006
2300462e:	60450513          	addi	a0,a0,1540 # 23006604 <uartAddr+0x4d8>
23004632:	ac1fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
			usbd_print_setup(setup);
23004636:	d75ff0ef          	jal	ra,230043aa <usbd_print_setup.constprop.14>
			return false;
2300463a:	4501                	li	a0,0
}
2300463c:	50b2                	lw	ra,44(sp)
2300463e:	5422                	lw	s0,40(sp)
23004640:	5492                	lw	s1,36(sp)
23004642:	5902                	lw	s2,32(sp)
23004644:	49f2                	lw	s3,28(sp)
23004646:	4a62                	lw	s4,24(sp)
23004648:	4ad2                	lw	s5,20(sp)
2300464a:	4b42                	lw	s6,16(sp)
2300464c:	4bb2                	lw	s7,12(sp)
2300464e:	4c22                	lw	s8,8(sp)
23004650:	4c92                	lw	s9,4(sp)
23004652:	6145                	addi	sp,sp,48
23004654:	8082                	ret
	usb_slist_for_each(i,&usbd_class_head)
23004656:	420257b7          	lui	a5,0x42025
2300465a:	4587a703          	lw	a4,1112(a5) # 42025458 <usbd_class_head>
			if(intf->custom_handler && (intf->intf_num == (setup->wIndex & 0xFF)))
2300465e:	00444603          	lbu	a2,4(s0)
	usb_slist_for_each(i,&usbd_class_head)
23004662:	db55                	beqz	a4,23004616 <usbd_setup_request_handler.constprop.4+0x3c>
		usb_slist_for_each(j,&class->intf_list)
23004664:	471c                	lw	a5,8(a4)
23004666:	e399                	bnez	a5,2300466c <usbd_setup_request_handler.constprop.4+0x92>
	usb_slist_for_each(i,&usbd_class_head)
23004668:	4318                	lw	a4,0(a4)
2300466a:	bfe5                	j	23004662 <usbd_setup_request_handler.constprop.4+0x88>
			if(intf->custom_handler && (intf->intf_num == (setup->wIndex & 0xFF)))
2300466c:	47d4                	lw	a3,12(a5)
2300466e:	ce99                	beqz	a3,2300468c <usbd_setup_request_handler.constprop.4+0xb2>
23004670:	0147c583          	lbu	a1,20(a5)
23004674:	00c59c63          	bne	a1,a2,2300468c <usbd_setup_request_handler.constprop.4+0xb2>
				return intf->custom_handler(setup, data, len);
23004678:	01040613          	addi	a2,s0,16
2300467c:	00840593          	addi	a1,s0,8
23004680:	63848513          	addi	a0,s1,1592
23004684:	9682                	jalr	a3
		if(!usbd_custom_request_handler(setup, data, len))
23004686:	f941                	bnez	a0,23004616 <usbd_setup_request_handler.constprop.4+0x3c>
	return true;
23004688:	4505                	li	a0,1
2300468a:	bf4d                	j	2300463c <usbd_setup_request_handler.constprop.4+0x62>
		usb_slist_for_each(j,&class->intf_list)
2300468c:	439c                	lw	a5,0(a5)
2300468e:	bfe1                	j	23004666 <usbd_setup_request_handler.constprop.4+0x8c>
	switch (setup->bRequest)
23004690:	00144583          	lbu	a1,1(s0)
23004694:	47ad                	li	a5,11
	uint16_t value = setup->wValue;
23004696:	00245503          	lhu	a0,2(s0)
	switch (setup->bRequest)
2300469a:	16b7e063          	bltu	a5,a1,230047fa <usbd_setup_request_handler.constprop.4+0x220>
2300469e:	23006737          	lui	a4,0x23006
230046a2:	00259793          	slli	a5,a1,0x2
230046a6:	33870713          	addi	a4,a4,824 # 23006338 <uartAddr+0x20c>
230046aa:	97ba                	add	a5,a5,a4
230046ac:	439c                	lw	a5,0(a5)
230046ae:	8782                	jr	a5
		*data = (uint8_t *)&usbd_core_cfg.remote_wakeup;
230046b0:	16040793          	addi	a5,s0,352
230046b4:	c41c                	sw	a5,8(s0)
			*len = 2;
230046b6:	4789                	li	a5,2
230046b8:	a0a5                	j	23004720 <usbd_setup_request_handler.constprop.4+0x146>
		if (value == USB_FEATURE_REMOTE_WAKEUP)
230046ba:	4785                	li	a5,1
230046bc:	f6f516e3          	bne	a0,a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
			usbd_core_cfg.remote_wakeup = 0;
230046c0:	16041023          	sh	zero,352(s0)
			usbd_event_notify_handler(USB_EVENT_CLEAR_REMOTE_WAKEUP,NULL);
230046c4:	4581                	li	a1,0
230046c6:	4529                	li	a0,10
				usbd_event_notify_handler(USB_EVENT_SET_HALT,NULL);
230046c8:	d0bff0ef          	jal	ra,230043d2 <usbd_event_notify_handler>
				break;
230046cc:	bf75                	j	23004688 <usbd_setup_request_handler.constprop.4+0xae>
		if (value == USB_FEATURE_REMOTE_WAKEUP)
230046ce:	4785                	li	a5,1
230046d0:	f4f51ce3          	bne	a0,a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
			usbd_core_cfg.remote_wakeup = 1;
230046d4:	16a41023          	sh	a0,352(s0)
			usbd_event_notify_handler(USB_EVENT_SET_REMOTE_WAKEUP,NULL);
230046d8:	4581                	li	a1,0
230046da:	4525                	li	a0,9
230046dc:	b7f5                	j	230046c8 <usbd_setup_request_handler.constprop.4+0xee>
		usbd_set_address(value);
230046de:	0ff57513          	andi	a0,a0,255
230046e2:	daafc0ef          	jal	ra,23000c8c <usbd_set_address>
	return ret;
230046e6:	b74d                	j	23004688 <usbd_setup_request_handler.constprop.4+0xae>
	type = GET_DESC_TYPE(type_index);
230046e8:	00855593          	srli	a1,a0,0x8
	if ((type == USB_DESCRIPTOR_TYPE_STRING) && (index == USB_OSDESC_STRING_DESC_INDEX)) 
230046ec:	478d                	li	a5,3
	type = GET_DESC_TYPE(type_index);
230046ee:	0ff5f713          	andi	a4,a1,255
	index = GET_DESC_INDEX(type_index);
230046f2:	0ff57613          	andi	a2,a0,255
	if ((type == USB_DESCRIPTOR_TYPE_STRING) && (index == USB_OSDESC_STRING_DESC_INDEX)) 
230046f6:	02f59763          	bne	a1,a5,23004724 <usbd_setup_request_handler.constprop.4+0x14a>
230046fa:	0ee00793          	li	a5,238
230046fe:	04f61763          	bne	a2,a5,2300474c <usbd_setup_request_handler.constprop.4+0x172>
		USBD_LOG("MS OS Descriptor string read\r\n");
23004702:	23006537          	lui	a0,0x23006
23004706:	4f850513          	addi	a0,a0,1272 # 230064f8 <uartAddr+0x3cc>
2300470a:	9e9fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
		if(!msosv1_desc)
2300470e:	420257b7          	lui	a5,0x42025
23004712:	4547a783          	lw	a5,1108(a5) # 42025454 <msosv1_desc>
23004716:	f00789e3          	beqz	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
		*data = (uint8_t*)msosv1_desc->string;
2300471a:	439c                	lw	a5,0(a5)
2300471c:	c41c                	sw	a5,8(s0)
		*len = sizeof(struct usb_msosv1_string_descriptor);
2300471e:	47c9                	li	a5,18
23004720:	c81c                	sw	a5,16(s0)
23004722:	b79d                	j	23004688 <usbd_setup_request_handler.constprop.4+0xae>
	else if (type == USB_DESCRIPTOR_TYPE_BINARY_OBJECT_STORE) 
23004724:	47bd                	li	a5,15
23004726:	00f59963          	bne	a1,a5,23004738 <usbd_setup_request_handler.constprop.4+0x15e>
		USBD_LOG("BOS descriptor string read\r\n");
2300472a:	23006537          	lui	a0,0x23006
2300472e:	51850513          	addi	a0,a0,1304 # 23006518 <uartAddr+0x3ec>
23004732:	9c1fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
	return ret;
23004736:	bdcd                	j	23004628 <usbd_setup_request_handler.constprop.4+0x4e>
	else if ((type == USB_DESCRIPTOR_TYPE_INTERFACE) || (type == USB_DESCRIPTOR_TYPE_ENDPOINT) ||
23004738:	ffc70793          	addi	a5,a4,-4
2300473c:	0ff7f793          	andi	a5,a5,255
23004740:	4685                	li	a3,1
23004742:	eef6f3e3          	bgeu	a3,a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
23004746:	479d                	li	a5,7
23004748:	eee7e0e3          	bltu	a5,a4,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
	p = (uint8_t *)usbd_core_cfg.descriptors;
2300474c:	4c1c                	lw	a5,24(s0)
	cur_index = 0U;
2300474e:	4681                	li	a3,0
	while (p[DESC_bLength] != 0U)
23004750:	0007c503          	lbu	a0,0(a5)
23004754:	e901                	bnez	a0,23004764 <usbd_setup_request_handler.constprop.4+0x18a>
		USBD_LOG_ERR("descriptor <type:%x,index:%x> not found!\r\n", type,index);
23004756:	23006537          	lui	a0,0x23006
2300475a:	62c50513          	addi	a0,a0,1580 # 2300662c <uartAddr+0x500>
2300475e:	995fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
	return ret;
23004762:	b5d9                	j	23004628 <usbd_setup_request_handler.constprop.4+0x4e>
		if (p[DESC_bDescriptorType] == type)
23004764:	0017c803          	lbu	a6,1(a5)
23004768:	00e81563          	bne	a6,a4,23004772 <usbd_setup_request_handler.constprop.4+0x198>
			if (cur_index == index)
2300476c:	2cd60a63          	beq	a2,a3,23004a40 <usbd_setup_request_handler.constprop.4+0x466>
			cur_index++;
23004770:	0685                	addi	a3,a3,1
		p += p[DESC_bLength];
23004772:	97aa                	add	a5,a5,a0
23004774:	bff1                	j	23004750 <usbd_setup_request_handler.constprop.4+0x176>
			*len = p[DESC_bLength];
23004776:	0007c783          	lbu	a5,0(a5)
2300477a:	b75d                	j	23004720 <usbd_setup_request_handler.constprop.4+0x146>
		*data = (uint8_t *)&usbd_core_cfg.configuration;
2300477c:	15e40793          	addi	a5,s0,350
		*data = (uint8_t *)&usbd_core_cfg.reserved;
23004780:	c41c                	sw	a5,8(s0)
		*len = 1;
23004782:	4785                	li	a5,1
23004784:	bf71                	j	23004720 <usbd_setup_request_handler.constprop.4+0x146>
		if (!usbd_set_configuration(value, 0))
23004786:	0ff57493          	andi	s1,a0,255
	if (config_index == 0U)
2300478a:	c08d                	beqz	s1,230047ac <usbd_setup_request_handler.constprop.4+0x1d2>
	uint8_t *p = (uint8_t *)usbd_core_cfg.descriptors;
2300478c:	01842903          	lw	s2,24(s0)
	bool found = false;
23004790:	4501                	li	a0,0
	uint8_t cur_config = 0xFF;
23004792:	0ff00993          	li	s3,255
	uint8_t cur_alt_setting = 0xFF;
23004796:	0ff00a13          	li	s4,255
		switch (p[DESC_bDescriptorType])
2300479a:	4a91                	li	s5,4
2300479c:	4b15                	li	s6,5
2300479e:	4b89                	li	s7,2
	while (p[DESC_bLength] != 0U)
230047a0:	00094783          	lbu	a5,0(s2)
230047a4:	ef99                	bnez	a5,230047c2 <usbd_setup_request_handler.constprop.4+0x1e8>
		if (!usbd_set_configuration(value, 0))
230047a6:	e80501e3          	beqz	a0,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
230047aa:	a039                	j	230047b8 <usbd_setup_request_handler.constprop.4+0x1de>
		USBD_LOG_ERR("Device not configured - invalid configuration\r\n");
230047ac:	23006537          	lui	a0,0x23006
230047b0:	53850513          	addi	a0,a0,1336 # 23006538 <uartAddr+0x40c>
230047b4:	93ffc0ef          	jal	ra,230010f2 <bflb_platform_printf>
			usbd_core_cfg.configuration = value;
230047b8:	14940f23          	sb	s1,350(s0)
			usbd_event_notify_handler(USB_EVENT_CONFIGURED,NULL);
230047bc:	4581                	li	a1,0
230047be:	4511                	li	a0,4
230047c0:	b721                	j	230046c8 <usbd_setup_request_handler.constprop.4+0xee>
		switch (p[DESC_bDescriptorType])
230047c2:	00194783          	lbu	a5,1(s2)
230047c6:	01578f63          	beq	a5,s5,230047e4 <usbd_setup_request_handler.constprop.4+0x20a>
230047ca:	03678063          	beq	a5,s6,230047ea <usbd_setup_request_handler.constprop.4+0x210>
230047ce:	01779763          	bne	a5,s7,230047dc <usbd_setup_request_handler.constprop.4+0x202>
			cur_config = p[CONF_DESC_bConfigurationValue];
230047d2:	00594983          	lbu	s3,5(s2)
			if (cur_config == config_index)
230047d6:	01349363          	bne	s1,s3,230047dc <usbd_setup_request_handler.constprop.4+0x202>
				found = true;
230047da:	4505                	li	a0,1
		p += p[DESC_bLength];
230047dc:	00094783          	lbu	a5,0(s2)
230047e0:	993e                	add	s2,s2,a5
230047e2:	bf7d                	j	230047a0 <usbd_setup_request_handler.constprop.4+0x1c6>
			cur_alt_setting =
230047e4:	00394a03          	lbu	s4,3(s2)
			break;
230047e8:	bfd5                	j	230047dc <usbd_setup_request_handler.constprop.4+0x202>
			if ((cur_config != config_index) ||
230047ea:	ff3499e3          	bne	s1,s3,230047dc <usbd_setup_request_handler.constprop.4+0x202>
230047ee:	fe0a17e3          	bnez	s4,230047dc <usbd_setup_request_handler.constprop.4+0x202>
			found = usbd_set_endpoint((struct usb_endpoint_descriptor *)p);
230047f2:	854a                	mv	a0,s2
230047f4:	b0bff0ef          	jal	ra,230042fe <usbd_set_endpoint>
			break;
230047f8:	b7d5                	j	230047dc <usbd_setup_request_handler.constprop.4+0x202>
		USBD_LOG_ERR("Illegal device req 0x%02x\r\n", setup->bRequest);
230047fa:	23006537          	lui	a0,0x23006
230047fe:	56850513          	addi	a0,a0,1384 # 23006568 <uartAddr+0x43c>
		USBD_LOG_ERR("Illegal ep req 0x%02x\r\n", setup->bRequest);
23004802:	8f1fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
		return false;
23004806:	b50d                	j	23004628 <usbd_setup_request_handler.constprop.4+0x4e>
	if (!is_device_configured() ||
23004808:	15e44783          	lbu	a5,350(s0)
2300480c:	e0078ee3          	beqz	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
	const uint8_t *p = (uint8_t *)usbd_core_cfg.descriptors;
23004810:	4c04                	lw	s1,24(s0)
		(!is_interface_valid((uint8_t)setup->wIndex)))
23004812:	00444903          	lbu	s2,4(s0)
		if (p[DESC_bDescriptorType] == USB_DESCRIPTOR_TYPE_CONFIGURATION)
23004816:	4689                	li	a3,2
	const uint8_t *p = (uint8_t *)usbd_core_cfg.descriptors;
23004818:	87a6                	mv	a5,s1
	while (p[DESC_bLength] != 0U)
2300481a:	0007c703          	lbu	a4,0(a5)
2300481e:	e00705e3          	beqz	a4,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
		if (p[DESC_bDescriptorType] == USB_DESCRIPTOR_TYPE_CONFIGURATION)
23004822:	0017c603          	lbu	a2,1(a5)
23004826:	00d61663          	bne	a2,a3,23004832 <usbd_setup_request_handler.constprop.4+0x258>
			if (interface < cfg_descr->bNumInterfaces)
2300482a:	0047c603          	lbu	a2,4(a5)
2300482e:	22c96463          	bltu	s2,a2,23004a56 <usbd_setup_request_handler.constprop.4+0x47c>
		p += p[DESC_bLength];
23004832:	97ba                	add	a5,a5,a4
23004834:	b7dd                	j	2300481a <usbd_setup_request_handler.constprop.4+0x240>
		*data = (uint8_t *)&usbd_core_cfg.reserved;
23004836:	16240793          	addi	a5,s0,354
2300483a:	b799                	j	23004780 <usbd_setup_request_handler.constprop.4+0x1a6>
		usbd_set_interface(setup->wIndex, setup->wValue);
2300483c:	00244a83          	lbu	s5,2(s0)
	uint8_t cur_alt_setting = 0xFF;
23004840:	0ff00993          	li	s3,255
	uint8_t cur_iface = 0xFF;
23004844:	0ff00413          	li	s0,255
	const uint8_t *if_desc = NULL;
23004848:	4a01                	li	s4,0
		switch (p[DESC_bDescriptorType])
2300484a:	4b91                	li	s7,4
2300484c:	4c15                	li	s8,5
	USBD_LOG("Close endpoint:0x%x type:%u\r\n",
2300484e:	23006cb7          	lui	s9,0x23006
	while (p[DESC_bLength] != 0U)
23004852:	0004c783          	lbu	a5,0(s1)
23004856:	e781                	bnez	a5,2300485e <usbd_setup_request_handler.constprop.4+0x284>
	usbd_event_notify_handler(USB_EVENT_SET_INTERFACE,(void*)if_desc);
23004858:	85d2                	mv	a1,s4
2300485a:	4521                	li	a0,8
2300485c:	b5b5                	j	230046c8 <usbd_setup_request_handler.constprop.4+0xee>
		switch (p[DESC_bDescriptorType])
2300485e:	0014c783          	lbu	a5,1(s1)
23004862:	01778863          	beq	a5,s7,23004872 <usbd_setup_request_handler.constprop.4+0x298>
23004866:	03878063          	beq	a5,s8,23004886 <usbd_setup_request_handler.constprop.4+0x2ac>
		p += p[DESC_bLength];
2300486a:	0004c783          	lbu	a5,0(s1)
2300486e:	94be                	add	s1,s1,a5
23004870:	b7cd                	j	23004852 <usbd_setup_request_handler.constprop.4+0x278>
			cur_iface = p[INTF_DESC_bInterfaceNumber];
23004872:	0024c403          	lbu	s0,2(s1)
			cur_alt_setting = p[INTF_DESC_bAlternateSetting];
23004876:	0034c983          	lbu	s3,3(s1)
			if (cur_iface == iface &&
2300487a:	fe8918e3          	bne	s2,s0,2300486a <usbd_setup_request_handler.constprop.4+0x290>
2300487e:	ff3a96e3          	bne	s5,s3,2300486a <usbd_setup_request_handler.constprop.4+0x290>
23004882:	8a26                	mv	s4,s1
23004884:	b7dd                	j	2300486a <usbd_setup_request_handler.constprop.4+0x290>
			if (cur_iface == iface)
23004886:	fe8912e3          	bne	s2,s0,2300486a <usbd_setup_request_handler.constprop.4+0x290>
				if (cur_alt_setting != alt_setting)
2300488a:	033a8063          	beq	s5,s3,230048aa <usbd_setup_request_handler.constprop.4+0x2d0>
	ep_cfg.ep_addr = ep_desc->bEndpointAddress;
2300488e:	0024cb03          	lbu	s6,2(s1)
	ep_cfg.ep_type = ep_desc->bmAttributes & USBD_EP_TYPE_MASK;
23004892:	0034c603          	lbu	a2,3(s1)
	USBD_LOG("Close endpoint:0x%x type:%u\r\n",
23004896:	584c8513          	addi	a0,s9,1412 # 23006584 <uartAddr+0x458>
2300489a:	85da                	mv	a1,s6
2300489c:	8a0d                	andi	a2,a2,3
2300489e:	855fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
	usbd_ep_close(ep_cfg.ep_addr);
230048a2:	855a                	mv	a0,s6
230048a4:	c06fc0ef          	jal	ra,23000caa <usbd_ep_close>
	return true;
230048a8:	b7c9                	j	2300486a <usbd_setup_request_handler.constprop.4+0x290>
					ret = usbd_set_endpoint(ep_desc);
230048aa:	8526                	mv	a0,s1
230048ac:	a53ff0ef          	jal	ra,230042fe <usbd_set_endpoint>
230048b0:	bf6d                	j	2300486a <usbd_setup_request_handler.constprop.4+0x290>
		USBD_LOG_ERR("Illegal interface req 0x%02x\r\n", setup->bRequest);
230048b2:	23006537          	lui	a0,0x23006
230048b6:	5a450513          	addi	a0,a0,1444 # 230065a4 <uartAddr+0x478>
230048ba:	b7a1                	j	23004802 <usbd_setup_request_handler.constprop.4+0x228>
	switch (setup->bRequest)
230048bc:	00144583          	lbu	a1,1(s0)
	uint8_t ep = (uint8_t)setup->wIndex;
230048c0:	00444483          	lbu	s1,4(s0)
	switch (setup->bRequest)
230048c4:	02e58e63          	beq	a1,a4,23004900 <usbd_setup_request_handler.constprop.4+0x326>
230048c8:	cd81                	beqz	a1,230048e0 <usbd_setup_request_handler.constprop.4+0x306>
230048ca:	478d                	li	a5,3
230048cc:	06f58263          	beq	a1,a5,23004930 <usbd_setup_request_handler.constprop.4+0x356>
230048d0:	47b1                	li	a5,12
230048d2:	d4f58be3          	beq	a1,a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
		USBD_LOG_ERR("Illegal ep req 0x%02x\r\n", setup->bRequest);
230048d6:	23006537          	lui	a0,0x23006
230048da:	5ec50513          	addi	a0,a0,1516 # 230065ec <uartAddr+0x4c0>
230048de:	b715                	j	23004802 <usbd_setup_request_handler.constprop.4+0x228>
		if (((ep & 0x7f) == 0) || is_device_configured())
230048e0:	07f4f793          	andi	a5,s1,127
230048e4:	c789                	beqz	a5,230048ee <usbd_setup_request_handler.constprop.4+0x314>
230048e6:	15e44783          	lbu	a5,350(s0)
230048ea:	d2078fe3          	beqz	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
			usbd_ep_is_stalled(ep, (uint8_t*)&usbd_core_cfg.remote_wakeup);
230048ee:	16040913          	addi	s2,s0,352
230048f2:	85ca                	mv	a1,s2
230048f4:	8526                	mv	a0,s1
230048f6:	bf0fc0ef          	jal	ra,23000ce6 <usbd_ep_is_stalled>
			*data = (uint8_t *)&usbd_core_cfg.remote_wakeup;
230048fa:	01242423          	sw	s2,8(s0)
230048fe:	bb65                	j	230046b6 <usbd_setup_request_handler.constprop.4+0xdc>
		if (setup->wValue == USB_FEATURE_ENDPOINT_STALL)
23004900:	00245783          	lhu	a5,2(s0)
23004904:	d20792e3          	bnez	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
			if (((ep & 0x7f) == 0) || is_device_configured())
23004908:	07f4f793          	andi	a5,s1,127
2300490c:	c789                	beqz	a5,23004916 <usbd_setup_request_handler.constprop.4+0x33c>
2300490e:	15e44783          	lbu	a5,350(s0)
23004912:	d0078be3          	beqz	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
				USBD_LOG_ERR("ep:%x clear halt\r\n", ep);
23004916:	23006537          	lui	a0,0x23006
2300491a:	85a6                	mv	a1,s1
2300491c:	5c450513          	addi	a0,a0,1476 # 230065c4 <uartAddr+0x498>
23004920:	fd2fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
				usbd_ep_clear_stall(ep);
23004924:	8526                	mv	a0,s1
23004926:	bb0fc0ef          	jal	ra,23000cd6 <usbd_ep_clear_stall>
				usbd_event_notify_handler(USB_EVENT_CLEAR_HALT,NULL);
2300492a:	4581                	li	a1,0
2300492c:	4531                	li	a0,12
2300492e:	bb69                	j	230046c8 <usbd_setup_request_handler.constprop.4+0xee>
		if (setup->wValue == USB_FEATURE_ENDPOINT_STALL)
23004930:	00245783          	lhu	a5,2(s0)
23004934:	ce079ae3          	bnez	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
			if (((ep & 0x7f) == 0) || is_device_configured())
23004938:	07f4f793          	andi	a5,s1,127
2300493c:	c789                	beqz	a5,23004946 <usbd_setup_request_handler.constprop.4+0x36c>
2300493e:	15e44783          	lbu	a5,350(s0)
23004942:	ce0783e3          	beqz	a5,23004628 <usbd_setup_request_handler.constprop.4+0x4e>
				USBD_LOG_ERR("ep:%x set halt\r\n", ep);
23004946:	23006537          	lui	a0,0x23006
2300494a:	85a6                	mv	a1,s1
2300494c:	5d850513          	addi	a0,a0,1496 # 230065d8 <uartAddr+0x4ac>
23004950:	fa2fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
				usbd_ep_set_stall(ep);
23004954:	8526                	mv	a0,s1
23004956:	b70fc0ef          	jal	ra,23000cc6 <usbd_ep_set_stall>
				usbd_event_notify_handler(USB_EVENT_SET_HALT,NULL);
2300495a:	4581                	li	a1,0
2300495c:	452d                	li	a0,11
2300495e:	b3ad                	j	230046c8 <usbd_setup_request_handler.constprop.4+0xee>
	else if (type == USB_REQUEST_CLASS)
23004960:	4705                	li	a4,1
23004962:	04e79663          	bne	a5,a4,230049ae <usbd_setup_request_handler.constprop.4+0x3d4>
	if (setup->bmRequestType_b.Recipient != USB_REQUEST_TO_INTERFACE)
23004966:	00044703          	lbu	a4,0(s0)
2300496a:	8b7d                	andi	a4,a4,31
2300496c:	00f70463          	beq	a4,a5,23004974 <usbd_setup_request_handler.constprop.4+0x39a>
			USBD_LOG_ERR("Handler Error %d\r\n", type);
23004970:	4585                	li	a1,1
23004972:	b965                	j	2300462a <usbd_setup_request_handler.constprop.4+0x50>
	usb_slist_for_each(i,&usbd_class_head)
23004974:	420257b7          	lui	a5,0x42025
23004978:	4587a703          	lw	a4,1112(a5) # 42025458 <usbd_class_head>
			if(intf->class_handler && (intf->intf_num == (setup->wIndex & 0xFF)))
2300497c:	00444603          	lbu	a2,4(s0)
	usb_slist_for_each(i,&usbd_class_head)
23004980:	db65                	beqz	a4,23004970 <usbd_setup_request_handler.constprop.4+0x396>
		usb_slist_for_each(j,&class->intf_list)
23004982:	471c                	lw	a5,8(a4)
23004984:	e399                	bnez	a5,2300498a <usbd_setup_request_handler.constprop.4+0x3b0>
	usb_slist_for_each(i,&usbd_class_head)
23004986:	4318                	lw	a4,0(a4)
23004988:	bfe5                	j	23004980 <usbd_setup_request_handler.constprop.4+0x3a6>
			if(intf->class_handler && (intf->intf_num == (setup->wIndex & 0xFF)))
2300498a:	43d4                	lw	a3,4(a5)
2300498c:	ce99                	beqz	a3,230049aa <usbd_setup_request_handler.constprop.4+0x3d0>
2300498e:	0147c583          	lbu	a1,20(a5)
23004992:	00c59c63          	bne	a1,a2,230049aa <usbd_setup_request_handler.constprop.4+0x3d0>
				return intf->class_handler(setup, data, len);
23004996:	01040613          	addi	a2,s0,16
2300499a:	00840593          	addi	a1,s0,8
2300499e:	63848513          	addi	a0,s1,1592
230049a2:	9682                	jalr	a3
		if (usbd_class_request_handler(setup, data, len) < 0)
230049a4:	ce0552e3          	bgez	a0,23004688 <usbd_setup_request_handler.constprop.4+0xae>
230049a8:	b7e1                	j	23004970 <usbd_setup_request_handler.constprop.4+0x396>
		usb_slist_for_each(j,&class->intf_list)
230049aa:	439c                	lw	a5,0(a5)
230049ac:	bfe1                	j	23004984 <usbd_setup_request_handler.constprop.4+0x3aa>
	else if (type == USB_REQUEST_VENDOR)
230049ae:	4709                	li	a4,2
		return false;
230049b0:	4501                	li	a0,0
	else if (type == USB_REQUEST_VENDOR)
230049b2:	c8e795e3          	bne	a5,a4,2300463c <usbd_setup_request_handler.constprop.4+0x62>
	if (setup->bmRequestType_b.Recipient != USB_REQUEST_TO_DEVICE)
230049b6:	00094783          	lbu	a5,0(s2)
230049ba:	8bfd                	andi	a5,a5,31
230049bc:	c399                	beqz	a5,230049c2 <usbd_setup_request_handler.constprop.4+0x3e8>
			USBD_LOG_ERR("Handler Error %d\r\n", type);
230049be:	4589                	li	a1,2
230049c0:	b1ad                	j	2300462a <usbd_setup_request_handler.constprop.4+0x50>
	if(msosv1_desc)
230049c2:	420259b7          	lui	s3,0x42025
230049c6:	45498993          	addi	s3,s3,1108 # 42025454 <msosv1_desc>
230049ca:	0009a783          	lw	a5,0(s3)
230049ce:	cf85                	beqz	a5,23004a06 <usbd_setup_request_handler.constprop.4+0x42c>
		if (setup->bRequest == msosv1_desc->vendor_code) 
230049d0:	00194703          	lbu	a4,1(s2)
230049d4:	0057c783          	lbu	a5,5(a5)
230049d8:	02f71763          	bne	a4,a5,23004a06 <usbd_setup_request_handler.constprop.4+0x42c>
			switch (setup->wIndex) {
230049dc:	00495703          	lhu	a4,4(s2)
230049e0:	4791                	li	a5,4
230049e2:	02f71263          	bne	a4,a5,23004a06 <usbd_setup_request_handler.constprop.4+0x42c>
				USBD_LOG("Handle Compat ID\r\n");
230049e6:	23006537          	lui	a0,0x23006
230049ea:	61850513          	addi	a0,a0,1560 # 23006618 <uartAddr+0x4ec>
230049ee:	f04fc0ef          	jal	ra,230010f2 <bflb_platform_printf>
				*data = (uint8_t*)msosv1_desc->compat_id;
230049f2:	0009a783          	lw	a5,0(s3)
230049f6:	4798                	lw	a4,8(a5)
				*len = msosv1_desc->compat_id_len;
230049f8:	00c7d783          	lhu	a5,12(a5)
				*data = (uint8_t*)msosv1_desc->compat_id;
230049fc:	00e92423          	sw	a4,8(s2)
				*len = msosv1_desc->compat_id_len;
23004a00:	00f92823          	sw	a5,16(s2)
				return 0;
23004a04:	b151                	j	23004688 <usbd_setup_request_handler.constprop.4+0xae>
	usb_slist_for_each(i,&usbd_class_head)
23004a06:	420257b7          	lui	a5,0x42025
23004a0a:	4587a903          	lw	s2,1112(a5) # 42025458 <usbd_class_head>
			if(intf->vendor_handler && !intf->vendor_handler(setup, data, len))
23004a0e:	01040a13          	addi	s4,s0,16
23004a12:	0421                	addi	s0,s0,8
	usb_slist_for_each(i,&usbd_class_head)
23004a14:	fa0905e3          	beqz	s2,230049be <usbd_setup_request_handler.constprop.4+0x3e4>
		usb_slist_for_each(j,&class->intf_list)
23004a18:	00892983          	lw	s3,8(s2)
23004a1c:	00099563          	bnez	s3,23004a26 <usbd_setup_request_handler.constprop.4+0x44c>
	usb_slist_for_each(i,&usbd_class_head)
23004a20:	00092903          	lw	s2,0(s2)
23004a24:	bfc5                	j	23004a14 <usbd_setup_request_handler.constprop.4+0x43a>
			if(intf->vendor_handler && !intf->vendor_handler(setup, data, len))
23004a26:	0089a783          	lw	a5,8(s3)
23004a2a:	e781                	bnez	a5,23004a32 <usbd_setup_request_handler.constprop.4+0x458>
		usb_slist_for_each(j,&class->intf_list)
23004a2c:	0009a983          	lw	s3,0(s3)
23004a30:	b7f5                	j	23004a1c <usbd_setup_request_handler.constprop.4+0x442>
			if(intf->vendor_handler && !intf->vendor_handler(setup, data, len))
23004a32:	8652                	mv	a2,s4
23004a34:	85a2                	mv	a1,s0
23004a36:	63848513          	addi	a0,s1,1592
23004a3a:	9782                	jalr	a5
23004a3c:	f965                	bnez	a0,23004a2c <usbd_setup_request_handler.constprop.4+0x452>
23004a3e:	b1a9                	j	23004688 <usbd_setup_request_handler.constprop.4+0xae>
		*data = p;
23004a40:	c41c                	sw	a5,8(s0)
		if (type == USB_DESCRIPTOR_TYPE_CONFIGURATION)
23004a42:	4689                	li	a3,2
23004a44:	d2d719e3          	bne	a4,a3,23004776 <usbd_setup_request_handler.constprop.4+0x19c>
			*len = (p[CONF_DESC_wTotalLength]) |
23004a48:	0027c703          	lbu	a4,2(a5)
23004a4c:	0037c783          	lbu	a5,3(a5)
23004a50:	07a2                	slli	a5,a5,0x8
23004a52:	8fd9                	or	a5,a5,a4
23004a54:	b1f1                	j	23004720 <usbd_setup_request_handler.constprop.4+0x146>
	switch (setup->bRequest)
23004a56:	00144583          	lbu	a1,1(s0)
23004a5a:	47ad                	li	a5,11
23004a5c:	e4b7ebe3          	bltu	a5,a1,230048b2 <usbd_setup_request_handler.constprop.4+0x2d8>
23004a60:	23006737          	lui	a4,0x23006
23004a64:	00259793          	slli	a5,a1,0x2
23004a68:	36870713          	addi	a4,a4,872 # 23006368 <uartAddr+0x23c>
23004a6c:	97ba                	add	a5,a5,a4
23004a6e:	439c                	lw	a5,0(a5)
23004a70:	8782                	jr	a5

23004a72 <usbd_desc_register>:

void usbd_desc_register(const uint8_t *desc)
{
	usbd_core_cfg.descriptors = desc;
23004a72:	420247b7          	lui	a5,0x42024
23004a76:	64a7a823          	sw	a0,1616(a5) # 42024650 <usbd_core_cfg+0x18>
}
23004a7a:	8082                	ret

23004a7c <usbd_class_register>:
	msosv1_desc = desc;
}

void usbd_class_register(usbd_class_t *class)
{
	usb_slist_add_tail(&usbd_class_head,&class->list);
23004a7c:	420257b7          	lui	a5,0x42025
23004a80:	45878793          	addi	a5,a5,1112 # 42025458 <usbd_class_head>
    l->next  = n;
}

static inline void usb_slist_add_tail(usb_slist_t *l, usb_slist_t *n)
{
    while (l->next) l = l->next;
23004a84:	4398                	lw	a4,0(a5)
23004a86:	e719                	bnez	a4,23004a94 <usbd_class_register+0x18>

    /* append the node to the tail */
    l->next = n;
23004a88:	c388                	sw	a0,0(a5)
    n->next = NULL;
23004a8a:	00052023          	sw	zero,0(a0)
    l->next = NULL;
23004a8e:	00052423          	sw	zero,8(a0)
	usb_slist_init(&class->intf_list);
}
23004a92:	8082                	ret
    while (l->next) l = l->next;
23004a94:	87ba                	mv	a5,a4
23004a96:	b7fd                	j	23004a84 <usbd_class_register+0x8>

23004a98 <usbd_class_add_interface>:

void usbd_class_add_interface(usbd_class_t *class,usbd_interface_t *intf)
{
	static uint8_t intf_offset = 0;
	intf->intf_num = intf_offset;
23004a98:	420257b7          	lui	a5,0x42025
23004a9c:	4507c703          	lbu	a4,1104(a5) # 42025450 <intf_offset.2915>
	usb_slist_add_tail(&class->intf_list,&intf->list);
23004aa0:	0521                	addi	a0,a0,8
23004aa2:	45078793          	addi	a5,a5,1104
	intf->intf_num = intf_offset;
23004aa6:	00e58a23          	sb	a4,20(a1)
23004aaa:	4114                	lw	a3,0(a0)
23004aac:	ea91                	bnez	a3,23004ac0 <usbd_class_add_interface+0x28>
    l->next = n;
23004aae:	c10c                	sw	a1,0(a0)
	usb_slist_init(&intf->ep_list);
	intf_offset++;
23004ab0:	0705                	addi	a4,a4,1
    n->next = NULL;
23004ab2:	0005a023          	sw	zero,0(a1)
    l->next = NULL;
23004ab6:	0005ac23          	sw	zero,24(a1)
23004aba:	00e78023          	sb	a4,0(a5)
}
23004abe:	8082                	ret
    while (l->next) l = l->next;
23004ac0:	8536                	mv	a0,a3
23004ac2:	b7e5                	j	23004aaa <usbd_class_add_interface+0x12>

23004ac4 <usbd_interface_add_endpoint>:

void usbd_interface_add_endpoint(usbd_interface_t *intf,usbd_endpoint_t *ep)
{
	usb_slist_add_tail(&intf->ep_list,&ep->list);
23004ac4:	0561                	addi	a0,a0,24
23004ac6:	411c                	lw	a5,0(a0)
23004ac8:	e789                	bnez	a5,23004ad2 <usbd_interface_add_endpoint+0xe>
    l->next = n;
23004aca:	c10c                	sw	a1,0(a0)
    n->next = NULL;
23004acc:	0005a023          	sw	zero,0(a1)
}
23004ad0:	8082                	ret
    while (l->next) l = l->next;
23004ad2:	853e                	mv	a0,a5
23004ad4:	bfcd                	j	23004ac6 <usbd_interface_add_endpoint+0x2>

23004ad6 <usb_device_is_configured>:

bool usb_device_is_configured(void)
{
	return usbd_core_cfg.configured;
}
23004ad6:	420247b7          	lui	a5,0x42024
23004ada:	7957c503          	lbu	a0,1941(a5) # 42024795 <usbd_core_cfg+0x15d>
23004ade:	8082                	ret

23004ae0 <device_register>:
 * @param flags the capabilities flag of device
 *
 * @return the error code, DEVICE_EOK on initialization successfully.
 */
int device_register(struct device *dev, const char *name, uint16_t flag)
{
23004ae0:	1141                	addi	sp,sp,-16
#define OBJECT_DEVICE_TYPE 0
#define OBJECT_FLAG_DEFAULT 0

    dlist_t *node;

    dlist_for_each(node, &device_head)
23004ae2:	420247b7          	lui	a5,0x42024
{
23004ae6:	c422                	sw	s0,8(sp)
23004ae8:	c606                	sw	ra,12(sp)
    dlist_for_each(node, &device_head)
23004aea:	25c7a403          	lw	s0,604(a5) # 4202425c <device_head>
23004aee:	25c78793          	addi	a5,a5,604
23004af2:	02f41563          	bne	s0,a5,23004b1c <device_register+0x3c>
        {
            return -DEVICE_EEXIST;
        }
    }

    dev->oflag = flag;
23004af6:	00c51b23          	sh	a2,22(a0)
    strncpy(dev->name, name, NAME_MAX);
23004afa:	4629                	li	a2,10
23004afc:	22b5                	jal	23004c68 <strncpy>

    dlist_insert_after(&device_head, &(dev->list));
23004afe:	00c50713          	addi	a4,a0,12
 * @param l list to insert it
 * @param n new node to be inserted
 */
static inline void dlist_insert_after(dlist_t *l, dlist_t *n)
{
    l->next->prev = n;
23004b02:	4014                	lw	a3,0(s0)
    n->next = l->next;

    l->next = n;
23004b04:	c018                	sw	a4,0(s0)
    l->next->prev = n;
23004b06:	c2d8                	sw	a4,4(a3)
    dev->status = DEVICE_REGISTERED;
23004b08:	4705                	li	a4,1
    n->next = l->next;
23004b0a:	c554                	sw	a3,12(a0)
    n->prev = l;
23004b0c:	c900                	sw	s0,16(a0)
23004b0e:	00e50a23          	sb	a4,20(a0)
    return DEVICE_EOK;
23004b12:	4501                	li	a0,0
}
23004b14:	40b2                	lw	ra,12(sp)
23004b16:	4422                	lw	s0,8(sp)
23004b18:	0141                	addi	sp,sp,16
23004b1a:	8082                	ret
        dev_obj = dlist_entry(node, struct device, list);
23004b1c:	ff440713          	addi	a4,s0,-12
        if (dev_obj == dev)
23004b20:	00e50463          	beq	a0,a4,23004b28 <device_register+0x48>
    dlist_for_each(node, &device_head)
23004b24:	4000                	lw	s0,0(s0)
23004b26:	b7f1                	j	23004af2 <device_register+0x12>
            return -DEVICE_EEXIST;
23004b28:	553d                	li	a0,-17
23004b2a:	b7ed                	j	23004b14 <device_register+0x34>

23004b2c <device_find>:
 * @param name the device driver's name
 *
 * @return the registered device driver on successful, or NULL on failure.
 */
struct device *device_find(const char *name)
{
23004b2c:	1101                	addi	sp,sp,-32
    struct device *dev;
    dlist_t *node;

    dlist_for_each(node, &device_head)
23004b2e:	420247b7          	lui	a5,0x42024
{
23004b32:	c84a                	sw	s2,16(sp)
    dlist_for_each(node, &device_head)
23004b34:	25c7a903          	lw	s2,604(a5) # 4202425c <device_head>
{
23004b38:	ca26                	sw	s1,20(sp)
23004b3a:	c64e                	sw	s3,12(sp)
23004b3c:	ce06                	sw	ra,28(sp)
23004b3e:	cc22                	sw	s0,24(sp)
23004b40:	89aa                	mv	s3,a0
23004b42:	25c78493          	addi	s1,a5,604
    dlist_for_each(node, &device_head)
23004b46:	00991463          	bne	s2,s1,23004b4e <device_find+0x22>
        if (strncmp(dev->name, name, NAME_MAX) == 0)
        {
            return dev;
        }
    }
    return NULL;
23004b4a:	4501                	li	a0,0
23004b4c:	a809                	j	23004b5e <device_find+0x32>
        if (strncmp(dev->name, name, NAME_MAX) == 0)
23004b4e:	ff490413          	addi	s0,s2,-12
23004b52:	4629                	li	a2,10
23004b54:	85ce                	mv	a1,s3
23004b56:	8522                	mv	a0,s0
23004b58:	20e5                	jal	23004c40 <strncmp>
23004b5a:	e909                	bnez	a0,23004b6c <device_find+0x40>
        dev = dlist_entry(node, struct device, list);
23004b5c:	8522                	mv	a0,s0
}
23004b5e:	40f2                	lw	ra,28(sp)
23004b60:	4462                	lw	s0,24(sp)
23004b62:	44d2                	lw	s1,20(sp)
23004b64:	4942                	lw	s2,16(sp)
23004b66:	49b2                	lw	s3,12(sp)
23004b68:	6105                	addi	sp,sp,32
23004b6a:	8082                	ret
    dlist_for_each(node, &device_head)
23004b6c:	00092903          	lw	s2,0(s2)
23004b70:	bfd9                	j	23004b46 <device_find+0x1a>

23004b72 <device_open>:
 */
int device_open(struct device *dev, uint16_t oflag)
{
    int retval = DEVICE_EOK;

    if ((dev->status == DEVICE_REGISTERED) || (dev->status == DEVICE_CLOSED))
23004b72:	01454783          	lbu	a5,20(a0)
23004b76:	4705                	li	a4,1
23004b78:	0fd7f793          	andi	a5,a5,253
23004b7c:	02e79b63          	bne	a5,a4,23004bb2 <device_open+0x40>
{
23004b80:	1141                	addi	sp,sp,-16
    {
        if (dev_open != NULL)
23004b82:	4d18                	lw	a4,24(a0)
{
23004b84:	c422                	sw	s0,8(sp)
23004b86:	c606                	sw	ra,12(sp)
23004b88:	c226                	sw	s1,4(sp)
23004b8a:	842a                	mv	s0,a0
    int retval = DEVICE_EOK;
23004b8c:	4781                	li	a5,0
        if (dev_open != NULL)
23004b8e:	cf01                	beqz	a4,23004ba6 <device_open+0x34>
23004b90:	84ae                	mv	s1,a1
        {
            retval = dev_open(dev, oflag);
23004b92:	9702                	jalr	a4
23004b94:	87aa                	mv	a5,a0
            dev->status = DEVICE_OPENED;
23004b96:	4709                	li	a4,2
23004b98:	00e40a23          	sb	a4,20(s0)
            dev->oflag |= oflag;
23004b9c:	01645703          	lhu	a4,22(s0)
23004ba0:	8cd9                	or	s1,s1,a4
23004ba2:	00941b23          	sh	s1,22(s0)
    else
    {
        retval = -DEVICE_EFAULT;
    }
    return retval;
}
23004ba6:	40b2                	lw	ra,12(sp)
23004ba8:	4422                	lw	s0,8(sp)
23004baa:	4492                	lw	s1,4(sp)
23004bac:	853e                	mv	a0,a5
23004bae:	0141                	addi	sp,sp,16
23004bb0:	8082                	ret
        retval = -DEVICE_EFAULT;
23004bb2:	57c9                	li	a5,-14
}
23004bb4:	853e                	mv	a0,a5
23004bb6:	8082                	ret

23004bb8 <device_control>:
 */
int device_control(struct device *dev, int cmd, void *args)
{
    int retval = DEVICE_EOK;

    if (dev->status >= DEVICE_REGISTERED)
23004bb8:	01454703          	lbu	a4,20(a0)
23004bbc:	c711                	beqz	a4,23004bc8 <device_control+0x10>
    {
        if (dev_control != NULL)
23004bbe:	02052303          	lw	t1,32(a0)
23004bc2:	00030563          	beqz	t1,23004bcc <device_control+0x14>
        {
            retval = dev_control(dev, cmd, args);
23004bc6:	8302                	jr	t1
        }
    }
    else
    {
        retval = -DEVICE_EFAULT;
23004bc8:	5549                	li	a0,-14
23004bca:	8082                	ret
    int retval = DEVICE_EOK;
23004bcc:	4501                	li	a0,0
    }
    return retval;
}
23004bce:	8082                	ret

23004bd0 <device_write>:
 */
int device_write(struct device *dev, uint32_t pos, const void *buffer, uint32_t size)
{
    int retval = DEVICE_EOK;

    if (dev->status == DEVICE_OPENED)
23004bd0:	01454803          	lbu	a6,20(a0)
23004bd4:	4709                	li	a4,2
23004bd6:	00e81763          	bne	a6,a4,23004be4 <device_write+0x14>
    {
        if (dev_write != NULL)
23004bda:	02452303          	lw	t1,36(a0)
23004bde:	00030563          	beqz	t1,23004be8 <device_write+0x18>
        {
            retval = dev_write(dev, pos, buffer, size);
23004be2:	8302                	jr	t1
        }
    }
    else
    {
        retval = -DEVICE_EFAULT;
23004be4:	5549                	li	a0,-14
23004be6:	8082                	ret
    int retval = DEVICE_EOK;
23004be8:	4501                	li	a0,0
    }
    return retval;
}
23004bea:	8082                	ret

23004bec <device_set_callback>:
 */
int device_set_callback(struct device *dev, void (*callback)(struct device *dev, void *args, uint32_t size, uint32_t event))
{
    int retval = DEVICE_EOK;

    if (dev->status > DEVICE_UNREGISTER)
23004bec:	01454783          	lbu	a5,20(a0)
23004bf0:	c791                	beqz	a5,23004bfc <device_set_callback+0x10>
    int retval = DEVICE_EOK;
23004bf2:	4781                	li	a5,0
    {
        if (callback != NULL)
23004bf4:	c191                	beqz	a1,23004bf8 <device_set_callback+0xc>
        {
            dev->callback = callback;
23004bf6:	d54c                	sw	a1,44(a0)
    else
    {
        retval = -DEVICE_EFAULT;
    }
    return retval;
23004bf8:	853e                	mv	a0,a5
23004bfa:	8082                	ret
        retval = -DEVICE_EFAULT;
23004bfc:	57c9                	li	a5,-14
23004bfe:	bfed                	j	23004bf8 <device_set_callback+0xc>

23004c00 <memcpy>:

void *memcpy(void *dst, const void *src, size_t n)
{
	const char *p = (char *)src;
	char *q = (char *)dst;
	while (n--) {
23004c00:	4781                	li	a5,0
23004c02:	00f61363          	bne	a2,a5,23004c08 <memcpy+0x8>
		*q++ = *p++;
	}
	return dst;
}
23004c06:	8082                	ret
		*q++ = *p++;
23004c08:	00f58733          	add	a4,a1,a5
23004c0c:	00074683          	lbu	a3,0(a4)
23004c10:	00f50733          	add	a4,a0,a5
23004c14:	0785                	addi	a5,a5,1
23004c16:	00d70023          	sb	a3,0(a4)
23004c1a:	b7e5                	j	23004c02 <memcpy+0x2>

23004c1c <memset>:
#include <stdint.h>

void *memset(void *dst, int c, size_t n)
{
	char *q = (char *)dst;
	while (n--) {
23004c1c:	962a                	add	a2,a2,a0
	char *q = (char *)dst;
23004c1e:	87aa                	mv	a5,a0
	while (n--) {
23004c20:	00c79363          	bne	a5,a2,23004c26 <memset+0xa>
		*q++ = c;
		__asm volatile ("":::"memory");
	}
	return dst;
}
23004c24:	8082                	ret
		*q++ = c;
23004c26:	0785                	addi	a5,a5,1
23004c28:	feb78fa3          	sb	a1,-1(a5)
		__asm volatile ("":::"memory");
23004c2c:	bfd5                	j	23004c20 <memset+0x4>

23004c2e <strlen>:

#include <string.h>

size_t strlen(const char *s)
{
	const char *ss = s;
23004c2e:	87aa                	mv	a5,a0
	while (*ss)
23004c30:	0007c703          	lbu	a4,0(a5)
23004c34:	e701                	bnez	a4,23004c3c <strlen+0xe>
		ss++;
	return ss - s;
}
23004c36:	40a78533          	sub	a0,a5,a0
23004c3a:	8082                	ret
		ss++;
23004c3c:	0785                	addi	a5,a5,1
23004c3e:	bfcd                	j	23004c30 <strlen+0x2>

23004c40 <strncmp>:
	const unsigned char *c1 = (const unsigned char *)s1;
	const unsigned char *c2 = (const unsigned char *)s2;
	unsigned char ch;
	int d = 0;

	while (n--) {
23004c40:	4701                	li	a4,0
23004c42:	00e61463          	bne	a2,a4,23004c4a <strncmp+0xa>
		d = (int)(ch = *c1++) - (int)*c2++;
23004c46:	4781                	li	a5,0
		if (d || !ch)
			break;
	}

	return d;
23004c48:	a831                	j	23004c64 <strncmp+0x24>
		d = (int)(ch = *c1++) - (int)*c2++;
23004c4a:	00e507b3          	add	a5,a0,a4
23004c4e:	0007c683          	lbu	a3,0(a5)
23004c52:	00e587b3          	add	a5,a1,a4
23004c56:	0007c783          	lbu	a5,0(a5)
23004c5a:	40f687b3          	sub	a5,a3,a5
		if (d || !ch)
23004c5e:	e399                	bnez	a5,23004c64 <strncmp+0x24>
23004c60:	0705                	addi	a4,a4,1
23004c62:	f2e5                	bnez	a3,23004c42 <strncmp+0x2>
}
23004c64:	853e                	mv	a0,a5
23004c66:	8082                	ret

23004c68 <strncpy>:
 */

#include <string.h>

char *strncpy(char *dst, const char *src, size_t n)
{
23004c68:	1141                	addi	sp,sp,-16
23004c6a:	c422                	sw	s0,8(sp)
23004c6c:	c606                	sw	ra,12(sp)
23004c6e:	842a                	mv	s0,a0
	char *q = dst;
	const char *p = src;
	char ch;

	while (n) {
23004c70:	ca09                	beqz	a2,23004c82 <strncpy+0x1a>
		n--;
		*q++ = ch = *p++;
23004c72:	0585                	addi	a1,a1,1
23004c74:	fff5c783          	lbu	a5,-1(a1)
23004c78:	0505                	addi	a0,a0,1
		n--;
23004c7a:	167d                	addi	a2,a2,-1
		*q++ = ch = *p++;
23004c7c:	fef50fa3          	sb	a5,-1(a0)
		if (!ch)
23004c80:	fbe5                	bnez	a5,23004c70 <strncpy+0x8>
			break;
	}

	/* The specs say strncpy() fills the entire buffer with NUL.  Sigh. */
	memset(q, 0, n);
23004c82:	4581                	li	a1,0
23004c84:	3f61                	jal	23004c1c <memset>

	return dst;
}
23004c86:	8522                	mv	a0,s0
23004c88:	40b2                	lw	ra,12(sp)
23004c8a:	4422                	lw	s0,8(sp)
23004c8c:	0141                	addi	sp,sp,16
23004c8e:	8082                	ret

23004c90 <vsnprintf>:
	const char *sarg;	/* %s string argument */
	char carg;		/* %c char argument */
	int slen;		/* String length */

	while ((ch = *p++)) {
		switch (state) {
23004c90:	230067b7          	lui	a5,0x23006
23004c94:	65878793          	addi	a5,a5,1624 # 23006658 <uartAddr+0x52c>
{
23004c98:	7135                	addi	sp,sp,-160
		switch (state) {
23004c9a:	cc3e                	sw	a5,24(sp)
	digits = (flags & FL_UPPER) ? ucdigits : lcdigits;
23004c9c:	230067b7          	lui	a5,0x23006
23004ca0:	6c478793          	addi	a5,a5,1732 # 230066c4 <ucdigits.1538>
23004ca4:	ce3e                	sw	a5,28(sp)
23004ca6:	230067b7          	lui	a5,0x23006
23004caa:	6b078793          	addi	a5,a5,1712 # 230066b0 <lcdigits.1537>
23004cae:	d03e                	sw	a5,32(sp)
					sarg = &carg;
					slen = 1;
					goto is_string;
				case 's':	/* String */
					sarg = va_arg(ap, const char *);
					sarg = sarg ? sarg : "(null)";
23004cb0:	230067b7          	lui	a5,0x23006
23004cb4:	6d878793          	addi	a5,a5,1752 # 230066d8 <ucdigits.1538+0x14>
23004cb8:	d23e                	sw	a5,36(sp)
23004cba:	230067b7          	lui	a5,0x23006
23004cbe:	66c78793          	addi	a5,a5,1644 # 2300666c <uartAddr+0x540>
{
23004cc2:	cd22                	sw	s0,152(sp)
23004cc4:	cb26                	sw	s1,148(sp)
23004cc6:	c94a                	sw	s2,144(sp)
23004cc8:	c552                	sw	s4,136(sp)
23004cca:	dede                	sw	s7,124(sp)
23004ccc:	dae6                	sw	s9,116(sp)
23004cce:	d8ea                	sw	s10,112(sp)
23004cd0:	d6ee                	sw	s11,108(sp)
23004cd2:	cf06                	sw	ra,156(sp)
23004cd4:	c74e                	sw	s3,140(sp)
23004cd6:	c356                	sw	s5,132(sp)
23004cd8:	c15a                	sw	s6,128(sp)
23004cda:	dce2                	sw	s8,120(sp)
23004cdc:	c62a                	sw	a0,12(sp)
23004cde:	8dae                	mv	s11,a1
23004ce0:	8436                	mv	s0,a3
	char *q = buffer;
23004ce2:	8caa                	mv	s9,a0
	} state = st_normal;
23004ce4:	4701                	li	a4,0
	unsigned int flags = 0;
23004ce6:	4481                	li	s1,0
	int prec = -1;
23004ce8:	5d7d                	li	s10,-1
	int width = 0;
23004cea:	4b81                	li	s7,0
	int rank = rank_int;	/* Default rank */
23004cec:	4901                	li	s2,0
	size_t o = 0;		/* Number of characters output */
23004cee:	4a01                	li	s4,0
23004cf0:	d43e                	sw	a5,40(sp)
	while ((ch = *p++)) {
23004cf2:	00160793          	addi	a5,a2,1
23004cf6:	c23e                	sw	a5,4(sp)
23004cf8:	00064783          	lbu	a5,0(a2)
23004cfc:	e78d                	bnez	a5,23004d26 <vsnprintf+0x96>
            break;
		}
	}

	/* Null-terminate the string */
	if (o < n)
23004cfe:	5fba7663          	bgeu	s4,s11,230052ea <vsnprintf+0x65a>
		*q = '\0';	/* No overflow */
23004d02:	000c8023          	sb	zero,0(s9)
	else if (n > 0)
		buffer[n - 1] = '\0';	/* Overflow - terminate at end of buffer */

	return o;
}
23004d06:	40fa                	lw	ra,156(sp)
23004d08:	446a                	lw	s0,152(sp)
23004d0a:	8552                	mv	a0,s4
23004d0c:	44da                	lw	s1,148(sp)
23004d0e:	494a                	lw	s2,144(sp)
23004d10:	49ba                	lw	s3,140(sp)
23004d12:	4a2a                	lw	s4,136(sp)
23004d14:	4a9a                	lw	s5,132(sp)
23004d16:	4b0a                	lw	s6,128(sp)
23004d18:	5bf6                	lw	s7,124(sp)
23004d1a:	5c66                	lw	s8,120(sp)
23004d1c:	5cd6                	lw	s9,116(sp)
23004d1e:	5d46                	lw	s10,112(sp)
23004d20:	5db6                	lw	s11,108(sp)
23004d22:	610d                	addi	sp,sp,160
23004d24:	8082                	ret
		switch (state) {
23004d26:	4691                	li	a3,4
23004d28:	02e6e263          	bltu	a3,a4,23004d4c <vsnprintf+0xbc>
23004d2c:	45e2                	lw	a1,24(sp)
23004d2e:	00271693          	slli	a3,a4,0x2
23004d32:	96ae                	add	a3,a3,a1
23004d34:	4294                	lw	a3,0(a3)
23004d36:	8682                	jr	a3
			if (ch == '%') {
23004d38:	02500693          	li	a3,37
23004d3c:	58d78763          	beq	a5,a3,230052ca <vsnprintf+0x63a>
				EMIT(ch);
23004d40:	01ba7563          	bgeu	s4,s11,23004d4a <vsnprintf+0xba>
23004d44:	00fc8023          	sb	a5,0(s9)
23004d48:	0c85                	addi	s9,s9,1
23004d4a:	0a05                	addi	s4,s4,1
				rank = SIZE_T_RANK;
23004d4c:	4612                	lw	a2,4(sp)
23004d4e:	b755                	j	23004cf2 <vsnprintf+0x62>
			switch (ch) {
23004d50:	1781                	addi	a5,a5,-32
23004d52:	0ff7f793          	andi	a5,a5,255
23004d56:	46c1                	li	a3,16
23004d58:	56f6ef63          	bltu	a3,a5,230052d6 <vsnprintf+0x646>
23004d5c:	56a2                	lw	a3,40(sp)
23004d5e:	078a                	slli	a5,a5,0x2
23004d60:	97b6                	add	a5,a5,a3
23004d62:	439c                	lw	a5,0(a5)
23004d64:	8782                	jr	a5
				flags |= FL_PLUS;
23004d66:	0044e493          	ori	s1,s1,4
				break;
23004d6a:	b7cd                	j	23004d4c <vsnprintf+0xbc>
				flags |= FL_TICK;
23004d6c:	0084e493          	ori	s1,s1,8
				break;
23004d70:	bff1                	j	23004d4c <vsnprintf+0xbc>
				flags |= FL_SPACE;
23004d72:	0104e493          	ori	s1,s1,16
				break;
23004d76:	bfd9                	j	23004d4c <vsnprintf+0xbc>
				flags |= FL_HASH;
23004d78:	0204e493          	ori	s1,s1,32
				break;
23004d7c:	bfc1                	j	23004d4c <vsnprintf+0xbc>
				flags |= FL_ZERO;
23004d7e:	0014e493          	ori	s1,s1,1
				break;
23004d82:	b7e9                	j	23004d4c <vsnprintf+0xbc>
			if (ch >= '0' && ch <= '9') {
23004d84:	fd078693          	addi	a3,a5,-48
23004d88:	0ff6f513          	andi	a0,a3,255
23004d8c:	45a5                	li	a1,9
23004d8e:	00a5e763          	bltu	a1,a0,23004d9c <vsnprintf+0x10c>
				width = width * 10 + (ch - '0');
23004d92:	47a9                	li	a5,10
23004d94:	02fb8bb3          	mul	s7,s7,a5
23004d98:	9bb6                	add	s7,s7,a3
23004d9a:	bf4d                	j	23004d4c <vsnprintf+0xbc>
			} else if (ch == '*') {
23004d9c:	02a00693          	li	a3,42
23004da0:	00d79c63          	bne	a5,a3,23004db8 <vsnprintf+0x128>
				width = va_arg(ap, int);
23004da4:	00042b83          	lw	s7,0(s0)
23004da8:	0411                	addi	s0,s0,4
				if (width < 0) {
23004daa:	fa0bd1e3          	bgez	s7,23004d4c <vsnprintf+0xbc>
					width = -width;
23004dae:	41700bb3          	neg	s7,s7
					flags |= FL_MINUS;
23004db2:	0024e493          	ori	s1,s1,2
23004db6:	bf59                	j	23004d4c <vsnprintf+0xbc>
			} else if (ch == '.') {
23004db8:	02e00713          	li	a4,46
23004dbc:	52e78063          	beq	a5,a4,230052dc <vsnprintf+0x64c>
23004dc0:	c232                	sw	a2,4(sp)
				state = st_modifiers;
23004dc2:	4711                	li	a4,4
23004dc4:	b761                	j	23004d4c <vsnprintf+0xbc>
			if (ch >= '0' && ch <= '9') {
23004dc6:	fd078693          	addi	a3,a5,-48
23004dca:	0ff6f513          	andi	a0,a3,255
23004dce:	45a5                	li	a1,9
23004dd0:	00a5e863          	bltu	a1,a0,23004de0 <vsnprintf+0x150>
				prec = prec * 10 + (ch - '0');
23004dd4:	47a9                	li	a5,10
23004dd6:	02fd0833          	mul	a6,s10,a5
23004dda:	01068d33          	add	s10,a3,a6
23004dde:	b7bd                	j	23004d4c <vsnprintf+0xbc>
			} else if (ch == '*') {
23004de0:	02a00693          	li	a3,42
23004de4:	fcd79ee3          	bne	a5,a3,23004dc0 <vsnprintf+0x130>
				prec = va_arg(ap, int);
23004de8:	00042d03          	lw	s10,0(s0)
23004dec:	00440793          	addi	a5,s0,4
				if (prec < 0)
23004df0:	000d5363          	bgez	s10,23004df6 <vsnprintf+0x166>
23004df4:	5d7d                	li	s10,-1
				prec = va_arg(ap, int);
23004df6:	843e                	mv	s0,a5
23004df8:	bf91                	j	23004d4c <vsnprintf+0xbc>
			switch (ch) {
23004dfa:	06c00693          	li	a3,108
23004dfe:	02d78f63          	beq	a5,a3,23004e3c <vsnprintf+0x1ac>
23004e02:	02f6e063          	bltu	a3,a5,23004e22 <vsnprintf+0x192>
23004e06:	06800693          	li	a3,104
23004e0a:	02d78763          	beq	a5,a3,23004e38 <vsnprintf+0x1a8>
23004e0e:	06a00693          	li	a3,106
23004e12:	4cd78863          	beq	a5,a3,230052e2 <vsnprintf+0x652>
23004e16:	04c00693          	li	a3,76
23004e1a:	02d79363          	bne	a5,a3,23004e40 <vsnprintf+0x1b0>
				rank += 2;
23004e1e:	0909                	addi	s2,s2,2
				break;
23004e20:	b735                	j	23004d4c <vsnprintf+0xbc>
23004e22:	07400693          	li	a3,116
23004e26:	4cd78063          	beq	a5,a3,230052e6 <vsnprintf+0x656>
23004e2a:	07a00693          	li	a3,122
23004e2e:	4ad78c63          	beq	a5,a3,230052e6 <vsnprintf+0x656>
23004e32:	07100693          	li	a3,113
23004e36:	b7d5                	j	23004e1a <vsnprintf+0x18a>
				rank--;	/* Shorter rank */
23004e38:	197d                	addi	s2,s2,-1
				break;
23004e3a:	bf09                	j	23004d4c <vsnprintf+0xbc>
				rank++;	/* Longer rank */
23004e3c:	0905                	addi	s2,s2,1
				break;
23004e3e:	b739                	j	23004d4c <vsnprintf+0xbc>
				if (rank < MIN_RANK)
23004e40:	4709                	li	a4,2
23004e42:	01275363          	bge	a4,s2,23004e48 <vsnprintf+0x1b8>
23004e46:	4909                	li	s2,2
23004e48:	5779                	li	a4,-2
23004e4a:	00e95363          	bge	s2,a4,23004e50 <vsnprintf+0x1c0>
23004e4e:	5979                	li	s2,-2
				switch (ch) {
23004e50:	06e00713          	li	a4,110
23004e54:	42e78c63          	beq	a5,a4,2300528c <vsnprintf+0x5fc>
23004e58:	04f76f63          	bltu	a4,a5,23004eb6 <vsnprintf+0x226>
23004e5c:	06300713          	li	a4,99
23004e60:	36e78e63          	beq	a5,a4,230051dc <vsnprintf+0x54c>
23004e64:	02f76163          	bltu	a4,a5,23004e86 <vsnprintf+0x1f6>
23004e68:	05000713          	li	a4,80
23004e6c:	1ee78263          	beq	a5,a4,23005050 <vsnprintf+0x3c0>
23004e70:	05800713          	li	a4,88
23004e74:	20e78763          	beq	a5,a4,23005082 <vsnprintf+0x3f2>
					EMIT(ch);
23004e78:	01ba7563          	bgeu	s4,s11,23004e82 <vsnprintf+0x1f2>
23004e7c:	00fc8023          	sb	a5,0(s9)
23004e80:	0c85                	addi	s9,s9,1
23004e82:	0a05                	addi	s4,s4,1
23004e84:	aa79                	j	23005022 <vsnprintf+0x392>
23004e86:	06400713          	li	a4,100
23004e8a:	00e78663          	beq	a5,a4,23004e96 <vsnprintf+0x206>
23004e8e:	06900713          	li	a4,105
23004e92:	fee793e3          	bne	a5,a4,23004e78 <vsnprintf+0x1e8>
					flags |= FL_SIGNED;
23004e96:	0404e493          	ori	s1,s1,64
					switch (rank) {
23004e9a:	1e090163          	beqz	s2,2300507c <vsnprintf+0x3ec>
23004e9e:	1b204c63          	bgtz	s2,23005056 <vsnprintf+0x3c6>
23004ea2:	57fd                	li	a5,-1
23004ea4:	1cf90963          	beq	s2,a5,23005076 <vsnprintf+0x3e6>
						val = (uintmax_t)(intmax_t)
23004ea8:	00040b03          	lb	s6,0(s0)
						val = (uintmax_t)(intmax_t)
23004eac:	41fb5c13          	srai	s8,s6,0x1f
						    va_arg(ap, signed long);
23004eb0:	0411                	addi	s0,s0,4
					base = 10;
23004eb2:	4729                	li	a4,10
						break;
23004eb4:	a03d                	j	23004ee2 <vsnprintf+0x252>
23004eb6:	07300713          	li	a4,115
23004eba:	3ae78263          	beq	a5,a4,2300525e <vsnprintf+0x5ce>
23004ebe:	16f76463          	bltu	a4,a5,23005026 <vsnprintf+0x396>
23004ec2:	06f00713          	li	a4,111
23004ec6:	1ce78263          	beq	a5,a4,2300508a <vsnprintf+0x3fa>
23004eca:	07000713          	li	a4,112
23004ece:	fae795e3          	bne	a5,a4,23004e78 <vsnprintf+0x1e8>
					val = (uintmax_t)(uintptr_t)
23004ed2:	00042b03          	lw	s6,0(s0)
					flags |= FL_HASH;
23004ed6:	0204e493          	ori	s1,s1,32
					val = (uintmax_t)(uintptr_t)
23004eda:	4c01                	li	s8,0
						va_arg(ap, void *);
23004edc:	0411                	addi	s0,s0,4
					base = 16;
23004ede:	4741                	li	a4,16
					prec = (CHAR_BIT*sizeof(void *)+3)/4;
23004ee0:	4d21                	li	s10,8
					sz = format_int(q, (o < n) ? n - o : 0,
23004ee2:	4301                	li	t1,0
23004ee4:	01ba7463          	bgeu	s4,s11,23004eec <vsnprintf+0x25c>
23004ee8:	414d8333          	sub	t1,s11,s4
	digits = (flags & FL_UPPER) ? ucdigits : lcdigits;
23004eec:	47f2                	lw	a5,28(sp)
23004eee:	0804f813          	andi	a6,s1,128
23004ef2:	c43e                	sw	a5,8(sp)
23004ef4:	00081463          	bnez	a6,23004efc <vsnprintf+0x26c>
23004ef8:	5782                	lw	a5,32(sp)
23004efa:	c43e                	sw	a5,8(sp)
	if (flags & FL_SIGNED && (intmax_t) val < 0) {
23004efc:	0404f793          	andi	a5,s1,64
	int minus = 0;
23004f00:	4e01                	li	t3,0
	if (flags & FL_SIGNED && (intmax_t) val < 0) {
23004f02:	cf81                	beqz	a5,23004f1a <vsnprintf+0x28a>
23004f04:	000c5b63          	bgez	s8,23004f1a <vsnprintf+0x28a>
		val = (uintmax_t) (-(intmax_t) val);
23004f08:	41600b33          	neg	s6,s6
23004f0c:	016037b3          	snez	a5,s6
23004f10:	41800c33          	neg	s8,s8
23004f14:	40fc0c33          	sub	s8,s8,a5
		minus = 1;
23004f18:	4e05                	li	t3,1
	int minus = 0;
23004f1a:	855a                	mv	a0,s6
23004f1c:	85e2                	mv	a1,s8
	int ndigits = 0, nchars;
23004f1e:	4981                	li	s3,0
		tmpval /= base;
23004f20:	41f75a93          	srai	s5,a4,0x1f
	while (tmpval) {
23004f24:	00b567b3          	or	a5,a0,a1
23004f28:	18079b63          	bnez	a5,230050be <vsnprintf+0x42e>
	if (flags & FL_HASH && base == 8) {
23004f2c:	0204f693          	andi	a3,s1,32
23004f30:	1a068563          	beqz	a3,230050da <vsnprintf+0x44a>
23004f34:	4621                	li	a2,8
23004f36:	87ea                	mv	a5,s10
23004f38:	00c71663          	bne	a4,a2,23004f44 <vsnprintf+0x2b4>
		if (prec < ndigits + 1)
23004f3c:	01a9cb63          	blt	s3,s10,23004f52 <vsnprintf+0x2c2>
			prec = ndigits + 1;
23004f40:	00198793          	addi	a5,s3,1
	if (ndigits < prec) {
23004f44:	00f9c763          	blt	s3,a5,23004f52 <vsnprintf+0x2c2>
	} else if (val == 0) {
23004f48:	018b6633          	or	a2,s6,s8
23004f4c:	87ce                	mv	a5,s3
23004f4e:	e211                	bnez	a2,23004f52 <vsnprintf+0x2c2>
		ndigits = 1;	/* Zero still requires space */
23004f50:	4785                	li	a5,1
	if (flags & FL_TICK) {
23004f52:	0084f613          	andi	a2,s1,8
		tickskip = ndigits;	/* No tick marks */
23004f56:	82be                	mv	t0,a5
	if (flags & FL_TICK) {
23004f58:	c611                	beqz	a2,23004f64 <vsnprintf+0x2d4>
		tickskip = (base == 16) ? 4 : 3;
23004f5a:	4641                	li	a2,16
23004f5c:	4291                	li	t0,4
23004f5e:	00c70363          	beq	a4,a2,23004f64 <vsnprintf+0x2d4>
23004f62:	428d                	li	t0,3
	ndigits += (ndigits - 1) / tickskip;
23004f64:	fff78613          	addi	a2,a5,-1
23004f68:	02564633          	div	a2,a2,t0
	if (minus || (flags & (FL_PLUS | FL_SPACE)))
23004f6c:	0144f893          	andi	a7,s1,20
23004f70:	01c8e8b3          	or	a7,a7,t3
		nchars++;	/* Need space for sign */
23004f74:	011038b3          	snez	a7,a7
	ndigits += (ndigits - 1) / tickskip;
23004f78:	97b2                	add	a5,a5,a2
		nchars++;	/* Need space for sign */
23004f7a:	98be                	add	a7,a7,a5
	if ((flags & FL_HASH) && base == 16) {
23004f7c:	c689                	beqz	a3,23004f86 <vsnprintf+0x2f6>
23004f7e:	4641                	li	a2,16
23004f80:	00c71363          	bne	a4,a2,23004f86 <vsnprintf+0x2f6>
		nchars += 2;	/* Add 0x for hex */
23004f84:	0889                	addi	a7,a7,2
	if (!(flags & (FL_MINUS | FL_ZERO)) && width > nchars) {
23004f86:	0034f613          	andi	a2,s1,3
23004f8a:	14061a63          	bnez	a2,230050de <vsnprintf+0x44e>
23004f8e:	1578dc63          	bge	a7,s7,230050e6 <vsnprintf+0x456>
23004f92:	411b89b3          	sub	s3,s7,a7
23004f96:	8ae6                	mv	s5,s9
	size_t o = 0, oo;
23004f98:	4581                	li	a1,0
			EMIT(' ');
23004f9a:	0065f763          	bgeu	a1,t1,23004fa8 <vsnprintf+0x318>
23004f9e:	02000513          	li	a0,32
23004fa2:	00aa8023          	sb	a0,0(s5)
23004fa6:	0a85                	addi	s5,s5,1
23004fa8:	0585                	addi	a1,a1,1
		while (width > nchars) {
23004faa:	ff3598e3          	bne	a1,s3,23004f9a <vsnprintf+0x30a>
			width--;
23004fae:	8ec6                	mv	t4,a7
	if (minus) {
23004fb0:	120e0f63          	beqz	t3,230050ee <vsnprintf+0x45e>
		EMIT('-');
23004fb4:	02d00593          	li	a1,45
23004fb8:	1469e263          	bltu	s3,t1,230050fc <vsnprintf+0x46c>
		EMIT(' ');
23004fbc:	0985                	addi	s3,s3,1
	if ((flags & FL_HASH) && base == 16) {
23004fbe:	ca8d                	beqz	a3,23004ff0 <vsnprintf+0x360>
23004fc0:	46c1                	li	a3,16
23004fc2:	02d71763          	bne	a4,a3,23004ff0 <vsnprintf+0x360>
		EMIT('0');
23004fc6:	0069f763          	bgeu	s3,t1,23004fd4 <vsnprintf+0x344>
23004fca:	03000693          	li	a3,48
23004fce:	00da8023          	sb	a3,0(s5)
23004fd2:	0a85                	addi	s5,s5,1
23004fd4:	00198693          	addi	a3,s3,1
		EMIT((flags & FL_UPPER) ? 'X' : 'x');
23004fd8:	0066fb63          	bgeu	a3,t1,23004fee <vsnprintf+0x35e>
23004fdc:	05800693          	li	a3,88
23004fe0:	00081463          	bnez	a6,23004fe8 <vsnprintf+0x358>
23004fe4:	07800693          	li	a3,120
23004fe8:	00da8023          	sb	a3,0(s5)
23004fec:	0a85                	addi	s5,s5,1
23004fee:	0989                	addi	s3,s3,2
	if ((flags & (FL_MINUS | FL_ZERO)) == FL_ZERO && width > ndigits) {
23004ff0:	4685                	li	a3,1
23004ff2:	00d61463          	bne	a2,a3,23004ffa <vsnprintf+0x36a>
23004ff6:	13d7c963          	blt	a5,t4,23005128 <vsnprintf+0x498>
	q += ndigits;		/* Advance the pointer to end of number */
23004ffa:	9abe                	add	s5,s5,a5
	o += ndigits;
23004ffc:	99be                	add	s3,s3,a5
	while (ndigits > 0) {
23004ffe:	41f75693          	srai	a3,a4,0x1f
	b4tick = tickskip;
23005002:	8396                	mv	t2,t0
	oo = o;			/* Temporary values */
23005004:	8f4e                	mv	t5,s3
	qq = q;
23005006:	8fd6                	mv	t6,s5
23005008:	c836                	sw	a3,16(sp)
	while (ndigits > 0) {
2300500a:	12f04263          	bgtz	a5,2300512e <vsnprintf+0x49e>
	while ((flags & FL_MINUS) && width > nchars) {
2300500e:	0024f713          	andi	a4,s1,2
23005012:	9ece                	add	t4,t4,s3
23005014:	c709                	beqz	a4,2300501e <vsnprintf+0x38e>
23005016:	413e87b3          	sub	a5,t4,s3
2300501a:	1af8c863          	blt	a7,a5,230051ca <vsnprintf+0x53a>
					q += sz;
2300501e:	9cce                	add	s9,s9,s3
					o += sz;
23005020:	9a4e                	add	s4,s4,s3
				state = st_normal;
23005022:	4701                	li	a4,0
					break;
23005024:	b325                	j	23004d4c <vsnprintf+0xbc>
23005026:	07500713          	li	a4,117
2300502a:	06e78263          	beq	a5,a4,2300508e <vsnprintf+0x3fe>
2300502e:	07800693          	li	a3,120
					base = 16;
23005032:	4741                	li	a4,16
23005034:	e4d792e3          	bne	a5,a3,23004e78 <vsnprintf+0x1e8>
					switch (rank) {
23005038:	08090063          	beqz	s2,230050b8 <vsnprintf+0x428>
2300503c:	05204b63          	bgtz	s2,23005092 <vsnprintf+0x402>
23005040:	57fd                	li	a5,-1
23005042:	06f90863          	beq	s2,a5,230050b2 <vsnprintf+0x422>
						val = (uintmax_t)
23005046:	00044b03          	lbu	s6,0(s0)
						val = (uintmax_t)
2300504a:	4c01                	li	s8,0
							va_arg(ap, unsigned
2300504c:	0411                	addi	s0,s0,4
						break;
2300504e:	bd51                	j	23004ee2 <vsnprintf+0x252>
					flags |= FL_UPPER;
23005050:	0804e493          	ori	s1,s1,128
23005054:	bdbd                	j	23004ed2 <vsnprintf+0x242>
23005056:	4785                	li	a5,1
23005058:	02f90263          	beq	s2,a5,2300507c <vsnprintf+0x3ec>
2300505c:	4789                	li	a5,2
2300505e:	e4f915e3          	bne	s2,a5,23004ea8 <vsnprintf+0x218>
						val = (uintmax_t)(intmax_t)
23005062:	041d                	addi	s0,s0,7
23005064:	ff847793          	andi	a5,s0,-8
23005068:	00878413          	addi	s0,a5,8
2300506c:	0007ab03          	lw	s6,0(a5)
23005070:	0047ac03          	lw	s8,4(a5)
23005074:	bd3d                	j	23004eb2 <vsnprintf+0x222>
						val = (uintmax_t)(intmax_t)
23005076:	00041b03          	lh	s6,0(s0)
2300507a:	bd0d                	j	23004eac <vsnprintf+0x21c>
						val = (uintmax_t)(intmax_t)
2300507c:	00042b03          	lw	s6,0(s0)
23005080:	b535                	j	23004eac <vsnprintf+0x21c>
					flags |= FL_UPPER;
23005082:	0804e493          	ori	s1,s1,128
					base = 16;
23005086:	4741                	li	a4,16
23005088:	bf45                	j	23005038 <vsnprintf+0x3a8>
					base = 8;
2300508a:	4721                	li	a4,8
2300508c:	b775                	j	23005038 <vsnprintf+0x3a8>
					base = 10;
2300508e:	4729                	li	a4,10
23005090:	b765                	j	23005038 <vsnprintf+0x3a8>
23005092:	4785                	li	a5,1
23005094:	02f90263          	beq	s2,a5,230050b8 <vsnprintf+0x428>
23005098:	4789                	li	a5,2
2300509a:	faf916e3          	bne	s2,a5,23005046 <vsnprintf+0x3b6>
						val = (uintmax_t)
2300509e:	041d                	addi	s0,s0,7
230050a0:	ff847793          	andi	a5,s0,-8
230050a4:	00878413          	addi	s0,a5,8
230050a8:	0007ab03          	lw	s6,0(a5)
230050ac:	0047ac03          	lw	s8,4(a5)
						break;
230050b0:	bd0d                	j	23004ee2 <vsnprintf+0x252>
						val = (uintmax_t)
230050b2:	00045b03          	lhu	s6,0(s0)
230050b6:	bf51                	j	2300504a <vsnprintf+0x3ba>
						val = (uintmax_t)
230050b8:	00042b03          	lw	s6,0(s0)
230050bc:	b779                	j	2300504a <vsnprintf+0x3ba>
		tmpval /= base;
230050be:	863a                	mv	a2,a4
230050c0:	86d6                	mv	a3,s5
230050c2:	d872                	sw	t3,48(sp)
230050c4:	d642                	sw	a6,44(sp)
230050c6:	ca1a                	sw	t1,20(sp)
230050c8:	c83a                	sw	a4,16(sp)
230050ca:	936fb0ef          	jal	ra,23000200 <__udivdi3>
		ndigits++;
230050ce:	0985                	addi	s3,s3,1
230050d0:	5e42                	lw	t3,48(sp)
230050d2:	5832                	lw	a6,44(sp)
230050d4:	4352                	lw	t1,20(sp)
230050d6:	4742                	lw	a4,16(sp)
230050d8:	b5b1                	j	23004f24 <vsnprintf+0x294>
	if (flags & FL_HASH && base == 8) {
230050da:	87ea                	mv	a5,s10
230050dc:	b5a5                	j	23004f44 <vsnprintf+0x2b4>
	if (!(flags & (FL_MINUS | FL_ZERO)) && width > nchars) {
230050de:	8ede                	mv	t4,s7
230050e0:	8ae6                	mv	s5,s9
	size_t o = 0, oo;
230050e2:	4981                	li	s3,0
230050e4:	b5f1                	j	23004fb0 <vsnprintf+0x320>
230050e6:	4981                	li	s3,0
	if (!(flags & (FL_MINUS | FL_ZERO)) && width > nchars) {
230050e8:	8ede                	mv	t4,s7
230050ea:	8ae6                	mv	s5,s9
230050ec:	b5d1                	j	23004fb0 <vsnprintf+0x320>
	} else if (flags & FL_PLUS) {
230050ee:	0044f593          	andi	a1,s1,4
230050f2:	c989                	beqz	a1,23005104 <vsnprintf+0x474>
		EMIT('+');
230050f4:	02b00593          	li	a1,43
230050f8:	ec69f2e3          	bgeu	s3,t1,23004fbc <vsnprintf+0x32c>
		EMIT(' ');
230050fc:	00ba8023          	sb	a1,0(s5)
23005100:	0a85                	addi	s5,s5,1
23005102:	bd6d                	j	23004fbc <vsnprintf+0x32c>
	} else if (flags & FL_SPACE) {
23005104:	0104f593          	andi	a1,s1,16
23005108:	ea058be3          	beqz	a1,23004fbe <vsnprintf+0x32e>
		EMIT(' ');
2300510c:	ea69f8e3          	bgeu	s3,t1,23004fbc <vsnprintf+0x32c>
23005110:	02000593          	li	a1,32
23005114:	b7e5                	j	230050fc <vsnprintf+0x46c>
			EMIT('0');
23005116:	0069f763          	bgeu	s3,t1,23005124 <vsnprintf+0x494>
2300511a:	03000693          	li	a3,48
2300511e:	00da8023          	sb	a3,0(s5)
23005122:	0a85                	addi	s5,s5,1
23005124:	0985                	addi	s3,s3,1
			width--;
23005126:	1efd                	addi	t4,t4,-1
		while (width > nchars) {
23005128:	ffd8c7e3          	blt	a7,t4,23005116 <vsnprintf+0x486>
2300512c:	b5f9                	j	23004ffa <vsnprintf+0x36a>
		if (!b4tick--) {
2300512e:	08038263          	beqz	t2,230051b2 <vsnprintf+0x522>
23005132:	13fd                	addi	t2,t2,-1
		qq--;
23005134:	ffff8693          	addi	a3,t6,-1
23005138:	c6fe                	sw	t6,76(sp)
2300513a:	ca36                	sw	a3,20(sp)
		oo--;
2300513c:	1f7d                	addi	t5,t5,-1
		ndigits--;
2300513e:	17fd                	addi	a5,a5,-1
		if (oo < n)
23005140:	026f7f63          	bgeu	t5,t1,2300517e <vsnprintf+0x4ee>
			*qq = digits[val % base];
23005144:	46c2                	lw	a3,16(sp)
23005146:	863a                	mv	a2,a4
23005148:	855a                	mv	a0,s6
2300514a:	85e2                	mv	a1,s8
2300514c:	c4be                	sw	a5,72(sp)
2300514e:	c29e                	sw	t2,68(sp)
23005150:	c0f6                	sw	t4,64(sp)
23005152:	de46                	sw	a7,60(sp)
23005154:	dc16                	sw	t0,56(sp)
23005156:	da7a                	sw	t5,52(sp)
23005158:	d81a                	sw	t1,48(sp)
2300515a:	d63a                	sw	a4,44(sp)
2300515c:	c02fb0ef          	jal	ra,2300055e <__umoddi3>
23005160:	47a2                	lw	a5,8(sp)
23005162:	4fb6                	lw	t6,76(sp)
23005164:	4396                	lw	t2,68(sp)
23005166:	953e                	add	a0,a0,a5
23005168:	00054683          	lbu	a3,0(a0)
2300516c:	47a6                	lw	a5,72(sp)
2300516e:	4e86                	lw	t4,64(sp)
23005170:	58f2                	lw	a7,60(sp)
23005172:	52e2                	lw	t0,56(sp)
23005174:	5f52                	lw	t5,52(sp)
23005176:	5342                	lw	t1,48(sp)
23005178:	5732                	lw	a4,44(sp)
2300517a:	fedf8fa3          	sb	a3,-1(t6)
		val /= base;
2300517e:	46c2                	lw	a3,16(sp)
23005180:	863a                	mv	a2,a4
23005182:	855a                	mv	a0,s6
23005184:	85e2                	mv	a1,s8
23005186:	c4be                	sw	a5,72(sp)
23005188:	c29e                	sw	t2,68(sp)
2300518a:	c0f6                	sw	t4,64(sp)
2300518c:	de46                	sw	a7,60(sp)
2300518e:	dc16                	sw	t0,56(sp)
23005190:	da7a                	sw	t5,52(sp)
23005192:	d81a                	sw	t1,48(sp)
23005194:	d63a                	sw	a4,44(sp)
23005196:	86afb0ef          	jal	ra,23000200 <__udivdi3>
2300519a:	8b2a                	mv	s6,a0
2300519c:	8c2e                	mv	s8,a1
		qq--;
2300519e:	4fd2                	lw	t6,20(sp)
230051a0:	47a6                	lw	a5,72(sp)
230051a2:	4396                	lw	t2,68(sp)
230051a4:	4e86                	lw	t4,64(sp)
230051a6:	58f2                	lw	a7,60(sp)
230051a8:	52e2                	lw	t0,56(sp)
230051aa:	5f52                	lw	t5,52(sp)
230051ac:	5342                	lw	t1,48(sp)
230051ae:	5732                	lw	a4,44(sp)
230051b0:	bda9                	j	2300500a <vsnprintf+0x37a>
230051b2:	1f7d                	addi	t5,t5,-1
			if (oo < n)
230051b4:	006f7663          	bgeu	t5,t1,230051c0 <vsnprintf+0x530>
				*qq = '_';
230051b8:	05f00693          	li	a3,95
230051bc:	fedf8fa3          	sb	a3,-1(t6)
230051c0:	1ffd                	addi	t6,t6,-1
230051c2:	17fd                	addi	a5,a5,-1
			b4tick = tickskip - 1;
230051c4:	fff28393          	addi	t2,t0,-1
230051c8:	b7b5                	j	23005134 <vsnprintf+0x4a4>
		EMIT(' ');
230051ca:	0069f763          	bgeu	s3,t1,230051d8 <vsnprintf+0x548>
230051ce:	02000793          	li	a5,32
230051d2:	00fa8023          	sb	a5,0(s5)
230051d6:	0a85                	addi	s5,s5,1
230051d8:	0985                	addi	s3,s3,1
		width--;
230051da:	bd2d                	j	23005014 <vsnprintf+0x384>
					carg = (char)va_arg(ap, int);
230051dc:	401c                	lw	a5,0(s0)
					slen = 1;
230051de:	4505                	li	a0,1
					carg = (char)va_arg(ap, int);
230051e0:	0411                	addi	s0,s0,4
230051e2:	04f10fa3          	sb	a5,95(sp)
					sarg = &carg;
230051e6:	05f10993          	addi	s3,sp,95
						if (prec != -1 && slen > prec)
230051ea:	57fd                	li	a5,-1
230051ec:	00fd0563          	beq	s10,a5,230051f6 <vsnprintf+0x566>
230051f0:	00ad5363          	bge	s10,a0,230051f6 <vsnprintf+0x566>
230051f4:	856a                	mv	a0,s10
						if (width > slen
230051f6:	03755863          	bge	a0,s7,23005226 <vsnprintf+0x596>
						    && !(flags & FL_MINUS)) {
230051fa:	0024f793          	andi	a5,s1,2
230051fe:	e785                	bnez	a5,23005226 <vsnprintf+0x596>
							    (flags & FL_ZERO) ?
23005200:	0014f793          	andi	a5,s1,1
							char pad =
23005204:	03000713          	li	a4,48
23005208:	e399                	bnez	a5,2300520e <vsnprintf+0x57e>
2300520a:	02000713          	li	a4,32
							while (width > slen) {
2300520e:	9bd2                	add	s7,s7,s4
23005210:	40ab8bb3          	sub	s7,s7,a0
								EMIT(pad);
23005214:	01ba7563          	bgeu	s4,s11,2300521e <vsnprintf+0x58e>
23005218:	00ec8023          	sb	a4,0(s9)
2300521c:	0c85                	addi	s9,s9,1
2300521e:	0a05                	addi	s4,s4,1
							while (width > slen) {
23005220:	ff7a1ae3          	bne	s4,s7,23005214 <vsnprintf+0x584>
								width--;
23005224:	8baa                	mv	s7,a0
						for (i = slen; i; i--) {
23005226:	4781                	li	a5,0
23005228:	00fa0733          	add	a4,s4,a5
2300522c:	04a79563          	bne	a5,a0,23005276 <vsnprintf+0x5e6>
23005230:	8a3a                	mv	s4,a4
				state = st_normal;
23005232:	4701                	li	a4,0
						if (width > slen
23005234:	b1755ce3          	bge	a0,s7,23004d4c <vsnprintf+0xbc>
						    && (flags & FL_MINUS)) {
23005238:	0024f793          	andi	a5,s1,2
2300523c:	b00788e3          	beqz	a5,23004d4c <vsnprintf+0xbc>
23005240:	9bd2                	add	s7,s7,s4
23005242:	40ab8bb3          	sub	s7,s7,a0
								EMIT(' ');
23005246:	01ba7763          	bgeu	s4,s11,23005254 <vsnprintf+0x5c4>
2300524a:	02000793          	li	a5,32
2300524e:	00fc8023          	sb	a5,0(s9)
23005252:	0c85                	addi	s9,s9,1
23005254:	0a05                	addi	s4,s4,1
							while (width > slen) {
23005256:	ff7a18e3          	bne	s4,s7,23005246 <vsnprintf+0x5b6>
								width--;
2300525a:	8baa                	mv	s7,a0
2300525c:	b3d9                	j	23005022 <vsnprintf+0x392>
					sarg = va_arg(ap, const char *);
2300525e:	00042983          	lw	s3,0(s0)
23005262:	00440a93          	addi	s5,s0,4
					sarg = sarg ? sarg : "(null)";
23005266:	00099363          	bnez	s3,2300526c <vsnprintf+0x5dc>
2300526a:	5992                	lw	s3,36(sp)
					slen = strlen(sarg);
2300526c:	854e                	mv	a0,s3
2300526e:	9c1ff0ef          	jal	ra,23004c2e <strlen>
					sarg = va_arg(ap, const char *);
23005272:	8456                	mv	s0,s5
					goto is_string;
23005274:	bf9d                	j	230051ea <vsnprintf+0x55a>
							EMIT(sch);
23005276:	01b77963          	bgeu	a4,s11,23005288 <vsnprintf+0x5f8>
							sch = *sarg++;
2300527a:	00f98733          	add	a4,s3,a5
2300527e:	00074703          	lbu	a4,0(a4)
							EMIT(sch);
23005282:	0c85                	addi	s9,s9,1
23005284:	feec8fa3          	sb	a4,-1(s9)
						for (i = slen; i; i--) {
23005288:	0785                	addi	a5,a5,1
2300528a:	bf79                	j	23005228 <vsnprintf+0x598>
						switch (rank) {
2300528c:	401c                	lw	a5,0(s0)
2300528e:	0411                	addi	s0,s0,4
23005290:	02090a63          	beqz	s2,230052c4 <vsnprintf+0x634>
23005294:	01204a63          	bgtz	s2,230052a8 <vsnprintf+0x618>
23005298:	577d                	li	a4,-1
2300529a:	02e90263          	beq	s2,a4,230052be <vsnprintf+0x62e>
								= o;
2300529e:	01478023          	sb	s4,0(a5)
				state = st_normal;
230052a2:	4701                	li	a4,0
							break;
230052a4:	5979                	li	s2,-2
230052a6:	b45d                	j	23004d4c <vsnprintf+0xbc>
230052a8:	4705                	li	a4,1
230052aa:	00e90d63          	beq	s2,a4,230052c4 <vsnprintf+0x634>
230052ae:	4709                	li	a4,2
230052b0:	fee917e3          	bne	s2,a4,2300529e <vsnprintf+0x60e>
								= o;
230052b4:	0147a023          	sw	s4,0(a5)
230052b8:	0007a223          	sw	zero,4(a5)
							break;
230052bc:	b39d                	j	23005022 <vsnprintf+0x392>
								= o;
230052be:	01479023          	sh	s4,0(a5)
							break;
230052c2:	b385                	j	23005022 <vsnprintf+0x392>
								= o;
230052c4:	0147a023          	sw	s4,0(a5)
							break;
230052c8:	bba9                	j	23005022 <vsnprintf+0x392>
				state = st_flags;
230052ca:	4705                	li	a4,1
				flags = 0;
230052cc:	4481                	li	s1,0
				prec = -1;
230052ce:	5d7d                	li	s10,-1
				width = 0;
230052d0:	4b81                	li	s7,0
				rank = rank_int;
230052d2:	4901                	li	s2,0
230052d4:	bca5                	j	23004d4c <vsnprintf+0xbc>
230052d6:	c232                	sw	a2,4(sp)
				state = st_width;
230052d8:	4709                	li	a4,2
230052da:	bc8d                	j	23004d4c <vsnprintf+0xbc>
				state = st_prec;
230052dc:	470d                	li	a4,3
				prec = 0;	/* Precision given */
230052de:	4d01                	li	s10,0
230052e0:	b4b5                	j	23004d4c <vsnprintf+0xbc>
				rank = INTMAX_RANK;
230052e2:	4909                	li	s2,2
230052e4:	b4a5                	j	23004d4c <vsnprintf+0xbc>
				rank = SIZE_T_RANK;
230052e6:	4905                	li	s2,1
230052e8:	b495                	j	23004d4c <vsnprintf+0xbc>
	else if (n > 0)
230052ea:	a00d8ee3          	beqz	s11,23004d06 <vsnprintf+0x76>
		buffer[n - 1] = '\0';	/* Overflow - terminate at end of buffer */
230052ee:	47b2                	lw	a5,12(sp)
230052f0:	01b78e33          	add	t3,a5,s11
230052f4:	fe0e0fa3          	sb	zero,-1(t3)
230052f8:	b439                	j	23004d06 <vsnprintf+0x76>

230052fa <blk_next>:
    return generic_fls(word) - 1;
}

static inline size_t blk_size(const mmheap_blk_t *blk)
{
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
230052fa:	415c                	lw	a5,4(a0)
}

/* Return location of next block after block of given size. */
static inline mmheap_blk_t *offset_to_blk(const void *ptr, int diff)
{
    return (mmheap_blk_t *)((uint32_t)ptr + diff);
230052fc:	0511                	addi	a0,a0,4
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
230052fe:	9bf1                	andi	a5,a5,-4
{
    mmheap_blk_t *next_blk;

    next_blk = offset_to_blk(blk_to_ptr(blk), blk_size(blk) - MMHEAP_BLK_HEADER_OVERHEAD);
    return next_blk;
}
23005300:	953e                	add	a0,a0,a5
23005302:	8082                	ret

23005304 <blk_link_next>:

/* Link a new block with its physical neighbor, return the neighbor. */
static mmheap_blk_t *blk_link_next(mmheap_blk_t *blk)
{
23005304:	1141                	addi	sp,sp,-16
23005306:	c422                	sw	s0,8(sp)
23005308:	c606                	sw	ra,12(sp)
2300530a:	842a                	mv	s0,a0
    mmheap_blk_t *next_blk;

    next_blk = blk_next(blk);
2300530c:	37fd                	jal	230052fa <blk_next>
    next_blk->prev_phys_blk = blk;
2300530e:	c100                	sw	s0,0(a0)
    return next_blk;
}
23005310:	40b2                	lw	ra,12(sp)
23005312:	4422                	lw	s0,8(sp)
23005314:	0141                	addi	sp,sp,16
23005316:	8082                	ret

23005318 <blk_mark_as_used>:
    blk_set_prev_free(next_blk);
    blk_set_free(blk);
}

static void blk_mark_as_used(mmheap_blk_t *blk)
{
23005318:	1141                	addi	sp,sp,-16
2300531a:	c422                	sw	s0,8(sp)
2300531c:	c606                	sw	ra,12(sp)
2300531e:	842a                	mv	s0,a0
    mmheap_blk_t *next_blk;

    next_blk = blk_next(blk);
23005320:	3fe9                	jal	230052fa <blk_next>
    blk->size &= ~MMHEAP_BLOCK_PREV_FREE;
23005322:	415c                	lw	a5,4(a0)
    blk_set_prev_used(next_blk);
    blk_set_used(blk);
}
23005324:	40b2                	lw	ra,12(sp)
    blk->size &= ~MMHEAP_BLOCK_PREV_FREE;
23005326:	9bf5                	andi	a5,a5,-3
23005328:	c15c                	sw	a5,4(a0)
    blk->size &= ~MMHEAP_BLOCK_CURR_FREE;
2300532a:	405c                	lw	a5,4(s0)
2300532c:	9bf9                	andi	a5,a5,-2
2300532e:	c05c                	sw	a5,4(s0)
}
23005330:	4422                	lw	s0,8(sp)
23005332:	0141                	addi	sp,sp,16
23005334:	8082                	ret

23005336 <blk_split>:
    return blk_size(blk) >= sizeof(mmheap_blk_t) + size;
}

/* Split a block into two, the second of which is free. */
static mmheap_blk_t *blk_split(mmheap_blk_t *blk, size_t size)
{
23005336:	1141                	addi	sp,sp,-16
23005338:	c422                	sw	s0,8(sp)
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
2300533a:	415c                	lw	a5,4(a0)
    return (mmheap_blk_t *)((uint32_t)ptr + diff);
2300533c:	00458413          	addi	s0,a1,4
23005340:	942a                	add	s0,s0,a0
    blk->size = size | (blk->size & MMHEAP_BLOCK_STATE_MASK);
23005342:	4058                	lw	a4,4(s0)
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
23005344:	9bf1                	andi	a5,a5,-4
    mmheap_blk_t   *remaining;
    size_t          remain_size;

    /* Calculate the amount of space left in the remaining block. */
    remaining   = offset_to_blk(blk_to_ptr(blk), size - MMHEAP_BLK_HEADER_OVERHEAD);
    remain_size = blk_size(blk) - (size + MMHEAP_BLK_HEADER_OVERHEAD);
23005346:	8f8d                	sub	a5,a5,a1
    blk->size = size | (blk->size & MMHEAP_BLOCK_STATE_MASK);
23005348:	8b0d                	andi	a4,a4,3
    remain_size = blk_size(blk) - (size + MMHEAP_BLK_HEADER_OVERHEAD);
2300534a:	17f1                	addi	a5,a5,-4
{
2300534c:	c606                	sw	ra,12(sp)
    blk->size = size | (blk->size & MMHEAP_BLOCK_STATE_MASK);
2300534e:	8fd9                	or	a5,a5,a4
23005350:	c05c                	sw	a5,4(s0)
23005352:	415c                	lw	a5,4(a0)
23005354:	8b8d                	andi	a5,a5,3
23005356:	8fcd                	or	a5,a5,a1
23005358:	c15c                	sw	a5,4(a0)
    next_blk = blk_link_next(blk);
2300535a:	8522                	mv	a0,s0
2300535c:	3765                	jal	23005304 <blk_link_next>
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
2300535e:	415c                	lw	a5,4(a0)

    blk_set_size(blk, size);
    blk_mark_as_free(remaining);

    return remaining;
}
23005360:	40b2                	lw	ra,12(sp)
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
23005362:	0027e793          	ori	a5,a5,2
23005366:	c15c                	sw	a5,4(a0)
    blk->size |= MMHEAP_BLOCK_CURR_FREE;
23005368:	405c                	lw	a5,4(s0)
}
2300536a:	8522                	mv	a0,s0
    blk->size |= MMHEAP_BLOCK_CURR_FREE;
2300536c:	0017e793          	ori	a5,a5,1
23005370:	c05c                	sw	a5,4(s0)
}
23005372:	4422                	lw	s0,8(sp)
23005374:	0141                	addi	sp,sp,16
23005376:	8082                	ret

23005378 <generic_fls.part.0>:
    if (!(x & 0xffff0000u)) {
23005378:	7741                	lui	a4,0xffff0
2300537a:	8f69                	and	a4,a4,a0
static int generic_fls(uint32_t x)
2300537c:	87aa                	mv	a5,a0
    int r = 32;
2300537e:	02000513          	li	a0,32
    if (!(x & 0xffff0000u)) {
23005382:	e319                	bnez	a4,23005388 <generic_fls.part.0+0x10>
        x <<= 16;
23005384:	07c2                	slli	a5,a5,0x10
        r -= 16;
23005386:	4541                	li	a0,16
    if (!(x & 0xff000000u)) {
23005388:	ff000737          	lui	a4,0xff000
2300538c:	8f7d                	and	a4,a4,a5
2300538e:	e319                	bnez	a4,23005394 <generic_fls.part.0+0x1c>
        x <<= 8;
23005390:	07a2                	slli	a5,a5,0x8
        r -= 8;
23005392:	1561                	addi	a0,a0,-8
    if (!(x & 0xf0000000u)) {
23005394:	f0000737          	lui	a4,0xf0000
23005398:	8f7d                	and	a4,a4,a5
2300539a:	e319                	bnez	a4,230053a0 <generic_fls.part.0+0x28>
        x <<= 4;
2300539c:	0792                	slli	a5,a5,0x4
        r -= 4;
2300539e:	1571                	addi	a0,a0,-4
    if (!(x & 0xc0000000u)) {
230053a0:	c0000737          	lui	a4,0xc0000
230053a4:	8f7d                	and	a4,a4,a5
230053a6:	e319                	bnez	a4,230053ac <generic_fls.part.0+0x34>
        x <<= 2;
230053a8:	078a                	slli	a5,a5,0x2
        r -= 2;
230053aa:	1579                	addi	a0,a0,-2
    if (!(x & 0x80000000u)) {
230053ac:	0007c363          	bltz	a5,230053b2 <generic_fls.part.0+0x3a>
        r -= 1;
230053b0:	157d                	addi	a0,a0,-1
}
230053b2:	8082                	ret

230053b4 <remove_free_block>:
    prev_blk = blk->prev_free;
230053b4:	455c                	lw	a5,12(a0)
    next_blk = blk->next_free;
230053b6:	4514                	lw	a3,8(a0)
    if (mmheap_ctl.blocks[fl][sl] == blk) {
230053b8:	42024737          	lui	a4,0x42024
230053bc:	79c70713          	addi	a4,a4,1948 # 4202479c <mmheap_ctl>
    next_blk->prev_free = prev_blk;
230053c0:	c6dc                	sw	a5,12(a3)
    prev_blk->next_free = next_blk;
230053c2:	c794                	sw	a3,8(a5)
    if (mmheap_ctl.blocks[fl][sl] == blk) {
230053c4:	00559793          	slli	a5,a1,0x5
230053c8:	97b2                	add	a5,a5,a2
230053ca:	02078793          	addi	a5,a5,32
230053ce:	078a                	slli	a5,a5,0x2
230053d0:	97ba                	add	a5,a5,a4
230053d2:	0047a803          	lw	a6,4(a5)
230053d6:	02a81d63          	bne	a6,a0,23005410 <remove_free_block+0x5c>
        mmheap_ctl.blocks[fl][sl] = next_blk;
230053da:	c3d4                	sw	a3,4(a5)
        if (next_blk == &mmheap_ctl.block_null) {
230053dc:	420247b7          	lui	a5,0x42024
230053e0:	7ac78793          	addi	a5,a5,1964 # 420247ac <mmheap_ctl+0x10>
230053e4:	02f69663          	bne	a3,a5,23005410 <remove_free_block+0x5c>
            mmheap_ctl.sl_bitmap[fl] &= ~(1 << sl);
230053e8:	00858693          	addi	a3,a1,8
230053ec:	068a                	slli	a3,a3,0x2
230053ee:	96ba                	add	a3,a3,a4
230053f0:	42c8                	lw	a0,4(a3)
230053f2:	4785                	li	a5,1
230053f4:	00c79633          	sll	a2,a5,a2
230053f8:	fff64613          	not	a2,a2
230053fc:	8e69                	and	a2,a2,a0
230053fe:	c2d0                	sw	a2,4(a3)
            if (!mmheap_ctl.sl_bitmap[fl]) {
23005400:	ea01                	bnez	a2,23005410 <remove_free_block+0x5c>
                mmheap_ctl.fl_bitmap &= ~(1 << fl);
23005402:	00b797b3          	sll	a5,a5,a1
23005406:	530c                	lw	a1,32(a4)
23005408:	fff7c793          	not	a5,a5
2300540c:	8fed                	and	a5,a5,a1
2300540e:	d31c                	sw	a5,32(a4)
}
23005410:	8082                	ret

23005412 <mapping_insert>:
{
23005412:	1101                	addi	sp,sp,-32
23005414:	cc22                	sw	s0,24(sp)
23005416:	ce06                	sw	ra,28(sp)
    if (size < MMHEAP_SMALL_BLOCK_SIZE) {
23005418:	07f00793          	li	a5,127
{
2300541c:	842a                	mv	s0,a0
    if (size < MMHEAP_SMALL_BLOCK_SIZE) {
2300541e:	00a7eb63          	bltu	a5,a0,23005434 <mapping_insert+0x22>
        sl = (int)size / (MMHEAP_SMALL_BLOCK_SIZE / MMHEAP_SL_INDEX_COUNT);
23005422:	40255413          	srai	s0,a0,0x2
        fl = 0;
23005426:	4501                	li	a0,0
    *fli = fl;
23005428:	c188                	sw	a0,0(a1)
}
2300542a:	40f2                	lw	ra,28(sp)
    *sli = sl;
2300542c:	c200                	sw	s0,0(a2)
}
2300542e:	4462                	lw	s0,24(sp)
23005430:	6105                	addi	sp,sp,32
23005432:	8082                	ret
23005434:	c632                	sw	a2,12(sp)
23005436:	c42e                	sw	a1,8(sp)
    if (!x)
23005438:	3781                	jal	23005378 <generic_fls.part.0>
        sl = ((int)size >> (fl - MMHEAP_SL_INDEX_COUNT_LOG2)) ^ (1 << MMHEAP_SL_INDEX_COUNT_LOG2);
2300543a:	ffa50793          	addi	a5,a0,-6
2300543e:	40f45433          	sra	s0,s0,a5
23005442:	02044413          	xori	s0,s0,32
        fl -= (MMHEAP_FL_INDEX_SHIFT - 1);
23005446:	1565                	addi	a0,a0,-7
23005448:	4632                	lw	a2,12(sp)
2300544a:	45a2                	lw	a1,8(sp)
2300544c:	bff1                	j	23005428 <mapping_insert+0x16>

2300544e <blk_remove>:
{
2300544e:	1101                	addi	sp,sp,-32
23005450:	cc22                	sw	s0,24(sp)
23005452:	842a                	mv	s0,a0
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
23005454:	4148                	lw	a0,4(a0)
    mapping_insert(blk_size(blk), &fl, &sl);
23005456:	0070                	addi	a2,sp,12
23005458:	002c                	addi	a1,sp,8
2300545a:	9971                	andi	a0,a0,-4
{
2300545c:	ce06                	sw	ra,28(sp)
    mapping_insert(blk_size(blk), &fl, &sl);
2300545e:	3f55                	jal	23005412 <mapping_insert>
    remove_free_block(blk, fl, sl);
23005460:	4632                	lw	a2,12(sp)
23005462:	45a2                	lw	a1,8(sp)
23005464:	8522                	mv	a0,s0
23005466:	37b9                	jal	230053b4 <remove_free_block>
}
23005468:	4462                	lw	s0,24(sp)
2300546a:	40f2                	lw	ra,28(sp)
2300546c:	6105                	addi	sp,sp,32
2300546e:	8082                	ret

23005470 <blk_merge_next>:
    return blk;
}

/* Merge a just-freed block with an adjacent free block. */
static mmheap_blk_t *blk_merge_next(mmheap_blk_t *blk)
{
23005470:	1141                	addi	sp,sp,-16
23005472:	c422                	sw	s0,8(sp)
23005474:	c606                	sw	ra,12(sp)
23005476:	c226                	sw	s1,4(sp)
23005478:	842a                	mv	s0,a0
    mmheap_blk_t *next_blk;

    next_blk = blk_next(blk);
2300547a:	e81ff0ef          	jal	ra,230052fa <blk_next>
    return blk->size & MMHEAP_BLOCK_CURR_FREE;
2300547e:	415c                	lw	a5,4(a0)
23005480:	8b85                	andi	a5,a5,1
    if (blk_is_free(next_blk)) {
23005482:	cf81                	beqz	a5,2300549a <blk_merge_next+0x2a>
23005484:	84aa                	mv	s1,a0
        blk_remove(next_blk);
23005486:	37e1                	jal	2300544e <blk_remove>
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
23005488:	40dc                	lw	a5,4(s1)
    prev_blk->size += blk_size(blk) + MMHEAP_BLK_HEADER_OVERHEAD;
2300548a:	4058                	lw	a4,4(s0)
    blk_link_next(prev_blk);
2300548c:	8522                	mv	a0,s0
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
2300548e:	9bf1                	andi	a5,a5,-4
    prev_blk->size += blk_size(blk) + MMHEAP_BLK_HEADER_OVERHEAD;
23005490:	0711                	addi	a4,a4,4
23005492:	97ba                	add	a5,a5,a4
23005494:	c05c                	sw	a5,4(s0)
    blk_link_next(prev_blk);
23005496:	e6fff0ef          	jal	ra,23005304 <blk_link_next>
        blk = blk_absorb(blk, next_blk);
    }

    return blk;
}
2300549a:	8522                	mv	a0,s0
2300549c:	40b2                	lw	ra,12(sp)
2300549e:	4422                	lw	s0,8(sp)
230054a0:	4492                	lw	s1,4(sp)
230054a2:	0141                	addi	sp,sp,16
230054a4:	8082                	ret

230054a6 <blk_insert>:
{
230054a6:	1101                	addi	sp,sp,-32
230054a8:	cc22                	sw	s0,24(sp)
230054aa:	842a                	mv	s0,a0
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
230054ac:	4148                	lw	a0,4(a0)
    mapping_insert(blk_size(blk), &fl, &sl);
230054ae:	0070                	addi	a2,sp,12
230054b0:	002c                	addi	a1,sp,8
230054b2:	9971                	andi	a0,a0,-4
{
230054b4:	ce06                	sw	ra,28(sp)
    mapping_insert(blk_size(blk), &fl, &sl);
230054b6:	3fb1                	jal	23005412 <mapping_insert>
    insert_free_block(blk, fl, sl);
230054b8:	46a2                	lw	a3,8(sp)
230054ba:	45b2                	lw	a1,12(sp)
    curr = mmheap_ctl.blocks[fl][sl];
230054bc:	42024737          	lui	a4,0x42024
230054c0:	00569793          	slli	a5,a3,0x5
230054c4:	97ae                	add	a5,a5,a1
230054c6:	02078793          	addi	a5,a5,32
230054ca:	79c70713          	addi	a4,a4,1948 # 4202479c <mmheap_ctl>
230054ce:	078a                	slli	a5,a5,0x2
230054d0:	97ba                	add	a5,a5,a4
230054d2:	43c8                	lw	a0,4(a5)
    blk->prev_free = &mmheap_ctl.block_null;
230054d4:	42024637          	lui	a2,0x42024
230054d8:	7ac60613          	addi	a2,a2,1964 # 420247ac <mmheap_ctl+0x10>
    blk->next_free = curr;
230054dc:	c408                	sw	a0,8(s0)
    blk->prev_free = &mmheap_ctl.block_null;
230054de:	c450                	sw	a2,12(s0)
    mmheap_ctl.fl_bitmap |= (1 << fl);
230054e0:	5310                	lw	a2,32(a4)
    curr->prev_free = blk;
230054e2:	c540                	sw	s0,12(a0)
}
230054e4:	40f2                	lw	ra,28(sp)
    mmheap_ctl.blocks[fl][sl] = blk;
230054e6:	c3c0                	sw	s0,4(a5)
    mmheap_ctl.fl_bitmap |= (1 << fl);
230054e8:	4785                	li	a5,1
230054ea:	00d79533          	sll	a0,a5,a3
    mmheap_ctl.sl_bitmap[fl] |= (1 << sl);
230054ee:	06a1                	addi	a3,a3,8
230054f0:	068a                	slli	a3,a3,0x2
    mmheap_ctl.fl_bitmap |= (1 << fl);
230054f2:	8e49                	or	a2,a2,a0
230054f4:	d310                	sw	a2,32(a4)
    mmheap_ctl.sl_bitmap[fl] |= (1 << sl);
230054f6:	9736                	add	a4,a4,a3
230054f8:	4354                	lw	a3,4(a4)
230054fa:	00b797b3          	sll	a5,a5,a1
}
230054fe:	4462                	lw	s0,24(sp)
    mmheap_ctl.sl_bitmap[fl] |= (1 << sl);
23005500:	8fd5                	or	a5,a5,a3
23005502:	c35c                	sw	a5,4(a4)
}
23005504:	6105                	addi	sp,sp,32
23005506:	8082                	ret

23005508 <blk_trim_free>:
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
23005508:	4158                	lw	a4,4(a0)
    return blk_size(blk) >= sizeof(mmheap_blk_t) + size;
2300550a:	01058693          	addi	a3,a1,16
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
2300550e:	9b71                	andi	a4,a4,-4
/* Trim any trailing block space off the end of a block, return to pool. */
static void blk_trim_free(mmheap_blk_t *blk, size_t size)
{
    mmheap_blk_t *remaining_blk;

    if (blk_can_split(blk, size)) {
23005510:	02d76763          	bltu	a4,a3,2300553e <blk_trim_free+0x36>
{
23005514:	1141                	addi	sp,sp,-16
23005516:	c606                	sw	ra,12(sp)
23005518:	c422                	sw	s0,8(sp)
2300551a:	c226                	sw	s1,4(sp)
2300551c:	842a                	mv	s0,a0
        remaining_blk = blk_split(blk, size);
2300551e:	e19ff0ef          	jal	ra,23005336 <blk_split>
23005522:	84aa                	mv	s1,a0
        blk_link_next(blk);
23005524:	8522                	mv	a0,s0
23005526:	ddfff0ef          	jal	ra,23005304 <blk_link_next>
        blk_set_prev_free(remaining_blk);
        blk_insert(remaining_blk);
    }
}
2300552a:	4422                	lw	s0,8(sp)
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
2300552c:	40dc                	lw	a5,4(s1)
}
2300552e:	40b2                	lw	ra,12(sp)
        blk_insert(remaining_blk);
23005530:	8526                	mv	a0,s1
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
23005532:	0027e793          	ori	a5,a5,2
23005536:	c0dc                	sw	a5,4(s1)
}
23005538:	4492                	lw	s1,4(sp)
2300553a:	0141                	addi	sp,sp,16
        blk_insert(remaining_blk);
2300553c:	b7ad                	j	230054a6 <blk_insert>
2300553e:	8082                	ret

23005540 <blk_locate_free>:

    return remaining_blk;
}

static mmheap_blk_t *blk_locate_free(size_t size)
{
23005540:	1101                	addi	sp,sp,-32
23005542:	ce06                	sw	ra,28(sp)
23005544:	cc22                	sw	s0,24(sp)
23005546:	ca26                	sw	s1,20(sp)
    int fl = 0, sl = 0;
23005548:	c402                	sw	zero,8(sp)
2300554a:	c602                	sw	zero,12(sp)
    mmheap_blk_t *blk = NULL;

    if (!size) {
2300554c:	e901                	bnez	a0,2300555c <blk_locate_free+0x1c>
        return NULL;
2300554e:	4401                	li	s0,0
    if (blk) {
        remove_free_block(blk, fl, sl);
    }

    return blk;
}
23005550:	8522                	mv	a0,s0
23005552:	40f2                	lw	ra,28(sp)
23005554:	4462                	lw	s0,24(sp)
23005556:	44d2                	lw	s1,20(sp)
23005558:	6105                	addi	sp,sp,32
2300555a:	8082                	ret
    if (size >= MMHEAP_SMALL_BLOCK_SIZE) {
2300555c:	07f00793          	li	a5,127
23005560:	842a                	mv	s0,a0
23005562:	00a7fa63          	bgeu	a5,a0,23005576 <blk_locate_free+0x36>
    if (!x)
23005566:	e13ff0ef          	jal	ra,23005378 <generic_fls.part.0>
        round = (1 << (__fls(size) - MMHEAP_SL_INDEX_COUNT_LOG2)) - 1;
2300556a:	1569                	addi	a0,a0,-6
2300556c:	4785                	li	a5,1
2300556e:	00a797b3          	sll	a5,a5,a0
23005572:	17fd                	addi	a5,a5,-1
        size += round;
23005574:	943e                	add	s0,s0,a5
    mapping_insert(size, fli, sli);
23005576:	8522                	mv	a0,s0
23005578:	0070                	addi	a2,sp,12
2300557a:	002c                	addi	a1,sp,8
2300557c:	e97ff0ef          	jal	ra,23005412 <mapping_insert>
    if (fl < MMHEAP_FL_INDEX_COUNT) {
23005580:	4422                	lw	s0,8(sp)
23005582:	47dd                	li	a5,23
23005584:	fc87c5e3          	blt	a5,s0,2300554e <blk_locate_free+0xe>
    sl_map = mmheap_ctl.sl_bitmap[fl] & (~0U << sl);
23005588:	420244b7          	lui	s1,0x42024
2300558c:	00840713          	addi	a4,s0,8
23005590:	79c48693          	addi	a3,s1,1948 # 4202479c <mmheap_ctl>
23005594:	070a                	slli	a4,a4,0x2
23005596:	4532                	lw	a0,12(sp)
23005598:	9736                	add	a4,a4,a3
2300559a:	4358                	lw	a4,4(a4)
2300559c:	57fd                	li	a5,-1
2300559e:	00a79533          	sll	a0,a5,a0
230055a2:	8d79                	and	a0,a0,a4
    if (!sl_map) {
230055a4:	79c48493          	addi	s1,s1,1948
230055a8:	e515                	bnez	a0,230055d4 <blk_locate_free+0x94>
        fl_map = mmheap_ctl.fl_bitmap & (~0U << (fl + 1));
230055aa:	5088                	lw	a0,32(s1)
230055ac:	0405                	addi	s0,s0,1
230055ae:	00879433          	sll	s0,a5,s0
230055b2:	8c69                	and	s0,s0,a0
        if (!fl_map) {
230055b4:	dc49                	beqz	s0,2300554e <blk_locate_free+0xe>
    return generic_fls(word & (~word + 1)) - 1;
230055b6:	40800533          	neg	a0,s0
230055ba:	8d61                	and	a0,a0,s0
        return 0;
230055bc:	4781                	li	a5,0
    if (!x)
230055be:	c501                	beqz	a0,230055c6 <blk_locate_free+0x86>
230055c0:	db9ff0ef          	jal	ra,23005378 <generic_fls.part.0>
230055c4:	87aa                	mv	a5,a0
    return generic_fls(word & (~word + 1)) - 1;
230055c6:	fff78413          	addi	s0,a5,-1
        sl_map = mmheap_ctl.sl_bitmap[fl];
230055ca:	079d                	addi	a5,a5,7
230055cc:	078a                	slli	a5,a5,0x2
230055ce:	97a6                	add	a5,a5,s1
230055d0:	43c8                	lw	a0,4(a5)
        *fli = fl;
230055d2:	c422                	sw	s0,8(sp)
    return generic_fls(word & (~word + 1)) - 1;
230055d4:	40a007b3          	neg	a5,a0
230055d8:	8d7d                	and	a0,a0,a5
        return 0;
230055da:	4601                	li	a2,0
    if (!x)
230055dc:	c501                	beqz	a0,230055e4 <blk_locate_free+0xa4>
230055de:	d9bff0ef          	jal	ra,23005378 <generic_fls.part.0>
230055e2:	862a                	mv	a2,a0
    return generic_fls(word & (~word + 1)) - 1;
230055e4:	167d                	addi	a2,a2,-1
    return mmheap_ctl.blocks[fl][sl];
230055e6:	0416                	slli	s0,s0,0x5
230055e8:	9432                	add	s0,s0,a2
230055ea:	02040413          	addi	s0,s0,32
230055ee:	040a                	slli	s0,s0,0x2
230055f0:	9426                	add	s0,s0,s1
230055f2:	4040                	lw	s0,4(s0)
    *sli = sl;
230055f4:	c632                	sw	a2,12(sp)
    if (blk) {
230055f6:	dc29                	beqz	s0,23005550 <blk_locate_free+0x10>
        remove_free_block(blk, fl, sl);
230055f8:	45a2                	lw	a1,8(sp)
230055fa:	8522                	mv	a0,s0
230055fc:	db9ff0ef          	jal	ra,230053b4 <remove_free_block>
23005600:	bf81                	j	23005550 <blk_locate_free+0x10>

23005602 <mmheap_alloc>:

    return mmheap_pool_add(pool_start, pool_size);
}

void *mmheap_alloc(size_t size)
{
23005602:	1101                	addi	sp,sp,-32
23005604:	ce06                	sw	ra,28(sp)
23005606:	cc22                	sw	s0,24(sp)
23005608:	85aa                	mv	a1,a0
    if (!size) {
2300560a:	cd19                	beqz	a0,23005628 <mmheap_alloc+0x26>
    return (x + (align - 1)) & ~(align - 1);
2300560c:	00350593          	addi	a1,a0,3
23005610:	ffc5f793          	andi	a5,a1,-4
    if (adjust_size > MMHEAP_BLK_SIZE_MAX) {
23005614:	40000737          	lui	a4,0x40000
        return 0;
23005618:	4581                	li	a1,0
    if (adjust_size > MMHEAP_BLK_SIZE_MAX) {
2300561a:	00f76763          	bltu	a4,a5,23005628 <mmheap_alloc+0x26>
    return adjust_size > MMHEAP_BLK_SIZE_MIN ? adjust_size : MMHEAP_BLK_SIZE_MIN;
2300561e:	85be                	mv	a1,a5
23005620:	47b1                	li	a5,12
23005622:	00f5f363          	bgeu	a1,a5,23005628 <mmheap_alloc+0x26>
23005626:	45b1                	li	a1,12
    size_t          adjust_size;
    mmheap_blk_t   *blk;

    adjust_size     = adjust_request_size(size, MMHEAP_ALIGN_SIZE);
    blk             = blk_locate_free(adjust_size);
23005628:	852e                	mv	a0,a1
2300562a:	c62e                	sw	a1,12(sp)
2300562c:	3f11                	jal	23005540 <blk_locate_free>
2300562e:	842a                	mv	s0,a0
    if (!blk) {
23005630:	c901                	beqz	a0,23005640 <mmheap_alloc+0x3e>
    blk_trim_free(blk, size);
23005632:	45b2                	lw	a1,12(sp)
23005634:	ed5ff0ef          	jal	ra,23005508 <blk_trim_free>
    blk_mark_as_used(blk);
23005638:	8522                	mv	a0,s0
2300563a:	cdfff0ef          	jal	ra,23005318 <blk_mark_as_used>
    return (void *)((uint32_t)blk + MMHEAP_BLK_START_OFFSET);
2300563e:	0421                	addi	s0,s0,8
        return NULL;
    }

    return blk_prepare_used(blk, adjust_size);
}
23005640:	8522                	mv	a0,s0
23005642:	40f2                	lw	ra,28(sp)
23005644:	4462                	lw	s0,24(sp)
23005646:	6105                	addi	sp,sp,32
23005648:	8082                	ret

2300564a <mmheap_free>:

void mmheap_free(void *ptr)
{
    mmheap_blk_t *blk;

    if (!ptr) {
2300564a:	cd29                	beqz	a0,230056a4 <mmheap_free+0x5a>
{
2300564c:	1141                	addi	sp,sp,-16
2300564e:	c422                	sw	s0,8(sp)
    return (mmheap_blk_t *)((uint32_t)ptr - MMHEAP_BLK_START_OFFSET);
23005650:	ff850413          	addi	s0,a0,-8
{
23005654:	c226                	sw	s1,4(sp)
23005656:	84aa                	mv	s1,a0
    next_blk = blk_link_next(blk);
23005658:	8522                	mv	a0,s0
{
2300565a:	c606                	sw	ra,12(sp)
    next_blk = blk_link_next(blk);
2300565c:	ca9ff0ef          	jal	ra,23005304 <blk_link_next>
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
23005660:	415c                	lw	a5,4(a0)
23005662:	0027e793          	ori	a5,a5,2
23005666:	c15c                	sw	a5,4(a0)
    blk->size |= MMHEAP_BLOCK_CURR_FREE;
23005668:	405c                	lw	a5,4(s0)
2300566a:	0017e793          	ori	a5,a5,1
2300566e:	c05c                	sw	a5,4(s0)
    return blk->size & MMHEAP_BLOCK_PREV_FREE;
23005670:	8b89                	andi	a5,a5,2
    if (blk_is_prev_free(blk)) {
23005672:	c385                	beqz	a5,23005692 <mmheap_free+0x48>
        prev_blk = blk_prev(blk);
23005674:	ff84a483          	lw	s1,-8(s1)
        blk_remove(prev_blk);
23005678:	8526                	mv	a0,s1
2300567a:	dd5ff0ef          	jal	ra,2300544e <blk_remove>
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
2300567e:	405c                	lw	a5,4(s0)
    prev_blk->size += blk_size(blk) + MMHEAP_BLK_HEADER_OVERHEAD;
23005680:	40d8                	lw	a4,4(s1)
    blk_link_next(prev_blk);
23005682:	8526                	mv	a0,s1
    return blk->size & MMHEAP_BLOCK_SIZE_MASK;
23005684:	9bf1                	andi	a5,a5,-4
    prev_blk->size += blk_size(blk) + MMHEAP_BLK_HEADER_OVERHEAD;
23005686:	97ba                	add	a5,a5,a4
23005688:	0791                	addi	a5,a5,4
2300568a:	c0dc                	sw	a5,4(s1)
    blk_link_next(prev_blk);
2300568c:	c79ff0ef          	jal	ra,23005304 <blk_link_next>
23005690:	8426                	mv	s0,s1
    }

    blk = blk_from_ptr(ptr);
    blk_mark_as_free(blk);
    blk = blk_merge_prev(blk);
    blk = blk_merge_next(blk);
23005692:	8522                	mv	a0,s0
23005694:	dddff0ef          	jal	ra,23005470 <blk_merge_next>
    blk_insert(blk);
}
23005698:	4422                	lw	s0,8(sp)
2300569a:	40b2                	lw	ra,12(sp)
2300569c:	4492                	lw	s1,4(sp)
2300569e:	0141                	addi	sp,sp,16
    blk_insert(blk);
230056a0:	e07ff06f          	j	230054a6 <blk_insert>
230056a4:	8082                	ret

230056a6 <mmheap_pool_add>:

    return p;
}

int mmheap_pool_add(void *pool_start, size_t pool_size)
{
230056a6:	1101                	addi	sp,sp,-32
230056a8:	cc22                	sw	s0,24(sp)
    return mmheap_ctl.pool_cnt == MMHEAP_POOL_MAX;
230056aa:	42024437          	lui	s0,0x42024
230056ae:	79c42683          	lw	a3,1948(s0) # 4202479c <mmheap_ctl>
{
230056b2:	ce06                	sw	ra,28(sp)
230056b4:	ca26                	sw	s1,20(sp)
230056b6:	c84a                	sw	s2,16(sp)
230056b8:	c64e                	sw	s3,12(sp)
    mmheap_blk_t   *curr_blk;
    mmheap_blk_t   *next_blk;
    size_t          size_aligned;

    if (mmheap_pool_is_full()) {
230056ba:	478d                	li	a5,3
230056bc:	06f68d63          	beq	a3,a5,23005736 <mmheap_pool_add+0x90>
230056c0:	79c40713          	addi	a4,s0,1948
    for (i = 0; i < mmheap_ctl.pool_cnt; ++i) {
230056c4:	4781                	li	a5,0
230056c6:	79c40913          	addi	s2,s0,1948
230056ca:	06d7c063          	blt	a5,a3,2300572a <mmheap_pool_add+0x84>

    if (mmheap_pool_is_exist(pool_start)) {
        return MEMHEAP_STATUS_ALREADY_EXIST;
    }

    size_aligned = align_down(pool_size - 2 * MMHEAP_BLK_HEADER_OVERHEAD, MMHEAP_ALIGN_SIZE);
230056ce:	15e1                	addi	a1,a1,-8

    if (((uint32_t)pool_start % MMHEAP_ALIGN_SIZE) != 0u) {
230056d0:	00357713          	andi	a4,a0,3
    return x - (x & (align - 1));
230056d4:	99f1                	andi	a1,a1,-4
        return MEMHEAP_STATUS_INVALID_ADDR;
230056d6:	57fd                	li	a5,-1
    if (((uint32_t)pool_start % MMHEAP_ALIGN_SIZE) != 0u) {
230056d8:	e329                	bnez	a4,2300571a <mmheap_pool_add+0x74>
    }

    if (size_aligned < MMHEAP_BLK_SIZE_MIN ||
230056da:	40000737          	lui	a4,0x40000
230056de:	ff458693          	addi	a3,a1,-12
230056e2:	1751                	addi	a4,a4,-12
        size_aligned > MMHEAP_BLK_SIZE_MAX) {
        return MEMHEAP_STATUS_INVALID_SIZE;
230056e4:	57f9                	li	a5,-2
    if (size_aligned < MMHEAP_BLK_SIZE_MIN ||
230056e6:	02d76a63          	bltu	a4,a3,2300571a <mmheap_pool_add+0x74>
    blk->size &= ~MMHEAP_BLOCK_PREV_FREE;
230056ea:	0015e593          	ori	a1,a1,1
    return (mmheap_blk_t *)((uint32_t)ptr + diff);
230056ee:	ffc50993          	addi	s3,a0,-4
    blk->size &= ~MMHEAP_BLOCK_PREV_FREE;
230056f2:	c10c                	sw	a1,0(a0)
230056f4:	84aa                	mv	s1,a0
     */
    curr_blk = offset_to_blk(pool_start, -MMHEAP_BLK_HEADER_OVERHEAD);
    blk_set_size(curr_blk, size_aligned);
    blk_set_free(curr_blk);
    blk_set_prev_used(curr_blk);
    blk_insert(curr_blk);
230056f6:	854e                	mv	a0,s3
230056f8:	dafff0ef          	jal	ra,230054a6 <blk_insert>

    /* Split the block to create a zero-size sentinel block. */
    next_blk = blk_link_next(curr_blk);
230056fc:	854e                	mv	a0,s3
230056fe:	c07ff0ef          	jal	ra,23005304 <blk_link_next>
    blk->size |= MMHEAP_BLOCK_PREV_FREE;
23005702:	4789                	li	a5,2
23005704:	c15c                	sw	a5,4(a0)
    mmheap_ctl.pool_start[mmheap_ctl.pool_cnt++] = pool_start;
23005706:	79c42783          	lw	a5,1948(s0)
2300570a:	00178713          	addi	a4,a5,1
2300570e:	078a                	slli	a5,a5,0x2
23005710:	97ca                	add	a5,a5,s2
23005712:	c3c4                	sw	s1,4(a5)
23005714:	78e42e23          	sw	a4,1948(s0)
    blk_set_used(next_blk);
    blk_set_prev_free(next_blk);

    mmheap_pool_record(pool_start);

    return MEMHEAP_STATUS_OK;
23005718:	4781                	li	a5,0
}
2300571a:	40f2                	lw	ra,28(sp)
2300571c:	4462                	lw	s0,24(sp)
2300571e:	44d2                	lw	s1,20(sp)
23005720:	4942                	lw	s2,16(sp)
23005722:	49b2                	lw	s3,12(sp)
23005724:	853e                	mv	a0,a5
23005726:	6105                	addi	sp,sp,32
23005728:	8082                	ret
        if (mmheap_ctl.pool_start[i] == pool_start) {
2300572a:	0711                	addi	a4,a4,4
2300572c:	4310                	lw	a2,0(a4)
2300572e:	00c50663          	beq	a0,a2,2300573a <mmheap_pool_add+0x94>
    for (i = 0; i < mmheap_ctl.pool_cnt; ++i) {
23005732:	0785                	addi	a5,a5,1
23005734:	bf59                	j	230056ca <mmheap_pool_add+0x24>
        return MEMHEAP_STATUS_OVERFLOW;
23005736:	57f5                	li	a5,-3
23005738:	b7cd                	j	2300571a <mmheap_pool_add+0x74>
        return MEMHEAP_STATUS_ALREADY_EXIST;
2300573a:	57ed                	li	a5,-5
2300573c:	bff9                	j	2300571a <mmheap_pool_add+0x74>

2300573e <mmheap_init_with_pool>:
    mmheap_ctl.pool_cnt = 0u;
2300573e:	420247b7          	lui	a5,0x42024
    mmheap_ctl.block_null.next_free = &mmheap_ctl.block_null;
23005742:	420246b7          	lui	a3,0x42024
        mmheap_ctl.pool_start[i] = (void *)NULL;
23005746:	79c78713          	addi	a4,a5,1948 # 4202479c <mmheap_ctl>
    mmheap_ctl.block_null.next_free = &mmheap_ctl.block_null;
2300574a:	7ac68613          	addi	a2,a3,1964 # 420247ac <mmheap_ctl+0x10>
    mmheap_ctl.pool_cnt = 0u;
2300574e:	7807ae23          	sw	zero,1948(a5)
        mmheap_ctl.pool_start[i] = (void *)NULL;
23005752:	00072223          	sw	zero,4(a4) # 40000004 <__ram_load_addr+0x1cff30e0>
23005756:	00072423          	sw	zero,8(a4)
2300575a:	00072623          	sw	zero,12(a4)
    mmheap_ctl.block_null.next_free = &mmheap_ctl.block_null;
2300575e:	cf10                	sw	a2,24(a4)
    mmheap_ctl.block_null.prev_free = &mmheap_ctl.block_null;
23005760:	cf50                	sw	a2,28(a4)
    mmheap_ctl.fl_bitmap = 0;
23005762:	02072023          	sw	zero,32(a4)
    for (i = 0; i < MMHEAP_FL_INDEX_COUNT; ++i) {
23005766:	06070893          	addi	a7,a4,96
    mmheap_ctl.fl_bitmap = 0;
2300576a:	79c78793          	addi	a5,a5,1948
2300576e:	7ac68693          	addi	a3,a3,1964
        for (j = 0; j < MMHEAP_SL_INDEX_COUNT; ++j) {
23005772:	02000313          	li	t1,32
        mmheap_ctl.sl_bitmap[i] = 0;
23005776:	02072223          	sw	zero,36(a4)
2300577a:	883e                	mv	a6,a5
        for (j = 0; j < MMHEAP_SL_INDEX_COUNT; ++j) {
2300577c:	4601                	li	a2,0
            mmheap_ctl.blocks[i][j] = &mmheap_ctl.block_null;
2300577e:	08d82223          	sw	a3,132(a6)
        for (j = 0; j < MMHEAP_SL_INDEX_COUNT; ++j) {
23005782:	0605                	addi	a2,a2,1
23005784:	0811                	addi	a6,a6,4
23005786:	fe661ce3          	bne	a2,t1,2300577e <mmheap_init_with_pool+0x40>
    for (i = 0; i < MMHEAP_FL_INDEX_COUNT; ++i) {
2300578a:	0711                	addi	a4,a4,4
2300578c:	08078793          	addi	a5,a5,128
23005790:	ff1713e3          	bne	a4,a7,23005776 <mmheap_init_with_pool+0x38>
    return mmheap_pool_add(pool_start, pool_size);
23005794:	bf09                	j	230056a6 <mmheap_pool_add>

23005796 <memcopy_to_fifo>:
void memcopy_to_fifo(void* fifo_addr,uint8_t* data,uint32_t length)
{
	uint8_t *p = (uint8_t *)fifo_addr;
	uint8_t *q = data;

	while (length--) {
23005796:	962e                	add	a2,a2,a1
23005798:	00c59363          	bne	a1,a2,2300579e <memcopy_to_fifo+0x8>
		*p = *q++;
	}
}
2300579c:	8082                	ret
		*p = *q++;
2300579e:	0585                	addi	a1,a1,1
230057a0:	fff5c783          	lbu	a5,-1(a1)
230057a4:	00f50023          	sb	a5,0(a0)
230057a8:	bfc5                	j	23005798 <memcopy_to_fifo+0x2>

230057aa <fifocopy_to_mem>:
void fifocopy_to_mem(void* fifo_addr,uint8_t* data,uint32_t length)
{
	uint8_t *p = (uint8_t *)fifo_addr;
	uint8_t *q = data;

	while (length--) {
230057aa:	962e                	add	a2,a2,a1
230057ac:	00c59363          	bne	a1,a2,230057b2 <fifocopy_to_mem+0x8>
		*q++ = *p;
	}
}
230057b0:	8082                	ret
		*q++ = *p;
230057b2:	00054783          	lbu	a5,0(a0)
230057b6:	0585                	addi	a1,a1,1
230057b8:	fef58fa3          	sb	a5,-1(a1)
230057bc:	bfc5                	j	230057ac <fifocopy_to_mem+0x2>

230057be <Ring_Buffer_Write_Copy>:
 *
 * @return None
 *
*******************************************************************************/
static void Ring_Buffer_Write_Copy(void* parameter,uint8_t* dest,uint32_t length)
{
230057be:	1141                	addi	sp,sp,-16
230057c0:	c422                	sw	s0,8(sp)
230057c2:	842a                	mv	s0,a0
230057c4:	852e                	mv	a0,a1
    uint8_t **src = (uint8_t **)parameter;
    
    ARCH_MemCpy_Fast(dest,*src,length);
230057c6:	400c                	lw	a1,0(s0)
{
230057c8:	c226                	sw	s1,4(sp)
230057ca:	c606                	sw	ra,12(sp)
230057cc:	84b2                	mv	s1,a2
    ARCH_MemCpy_Fast(dest,*src,length);
230057ce:	ff010097          	auipc	ra,0xff010
230057d2:	fd6080e7          	jalr	-42(ra) # 220157a4 <arch_memcpy_fast>
    *src += length;
230057d6:	4010                	lw	a2,0(s0)
}
230057d8:	40b2                	lw	ra,12(sp)
    *src += length;
230057da:	9626                	add	a2,a2,s1
230057dc:	c010                	sw	a2,0(s0)
}
230057de:	4422                	lw	s0,8(sp)
230057e0:	4492                	lw	s1,4(sp)
230057e2:	0141                	addi	sp,sp,16
230057e4:	8082                	ret

230057e6 <Ring_Buffer_Read_Copy>:
 *
 * @return None
 *
*******************************************************************************/
static void Ring_Buffer_Read_Copy(void* parameter,uint8_t* data,uint32_t length)
{
230057e6:	1141                	addi	sp,sp,-16
230057e8:	c422                	sw	s0,8(sp)
230057ea:	842a                	mv	s0,a0
    uint8_t **dest = (uint8_t **)parameter;
    
    ARCH_MemCpy_Fast(*dest,data,length);
230057ec:	4108                	lw	a0,0(a0)
{
230057ee:	c226                	sw	s1,4(sp)
230057f0:	c606                	sw	ra,12(sp)
230057f2:	84b2                	mv	s1,a2
    ARCH_MemCpy_Fast(*dest,data,length);
230057f4:	ff010097          	auipc	ra,0xff010
230057f8:	fb0080e7          	jalr	-80(ra) # 220157a4 <arch_memcpy_fast>
    *dest += length;
230057fc:	4010                	lw	a2,0(s0)
}
230057fe:	40b2                	lw	ra,12(sp)
    *dest += length;
23005800:	9626                	add	a2,a2,s1
23005802:	c010                	sw	a2,0(s0)
}
23005804:	4422                	lw	s0,8(sp)
23005806:	4492                	lw	s1,4(sp)
23005808:	0141                	addi	sp,sp,16
2300580a:	8082                	ret

2300580c <Ring_Buffer_Init>:
    rbType->pointer = buffer;
2300580c:	c10c                	sw	a1,0(a0)
    rbType->readMirror = 0;
2300580e:	00050223          	sb	zero,4(a0)
    rbType->readIndex = 0;
23005812:	00052423          	sw	zero,8(a0)
    rbType->writeMirror = 0;
23005816:	00050623          	sb	zero,12(a0)
    rbType->writeIndex = 0;
2300581a:	00052823          	sw	zero,16(a0)
    rbType->size = size;
2300581e:	c950                	sw	a2,20(a0)
    rbType->lock = lockCb;
23005820:	cd14                	sw	a3,24(a0)
    rbType->unlock = unlockCb;
23005822:	cd58                	sw	a4,28(a0)
}
23005824:	4501                	li	a0,0
23005826:	8082                	ret

23005828 <Ring_Buffer_Get_Length>:
 *
 * @return Length of data
 *
*******************************************************************************/
uint32_t Ring_Buffer_Get_Length(Ring_Buffer_Type* rbType)
{
23005828:	1101                	addi	sp,sp,-32
    uint32_t writeMirror = 0;
    uint32_t readIndex = 0;
    uint32_t writeIndex = 0;
    uint32_t size = 0;
    
    if(rbType->lock != NULL){
2300582a:	4d1c                	lw	a5,24(a0)
{
2300582c:	cc22                	sw	s0,24(sp)
2300582e:	ce06                	sw	ra,28(sp)
23005830:	ca26                	sw	s1,20(sp)
23005832:	c84a                	sw	s2,16(sp)
23005834:	c64e                	sw	s3,12(sp)
23005836:	c452                	sw	s4,8(sp)
23005838:	c256                	sw	s5,4(sp)
2300583a:	842a                	mv	s0,a0
    if(rbType->lock != NULL){
2300583c:	c391                	beqz	a5,23005840 <Ring_Buffer_Get_Length+0x18>
        rbType->lock();
2300583e:	9782                	jalr	a5
    writeMirror = rbType->writeMirror;
    readIndex = rbType->readIndex;
    writeIndex = rbType->writeIndex;
    size = rbType->size;
    
    if(rbType->unlock != NULL){
23005840:	4c5c                	lw	a5,28(s0)
    readMirror = rbType->readMirror;
23005842:	00444a83          	lbu	s5,4(s0)
    writeMirror = rbType->writeMirror;
23005846:	00c44a03          	lbu	s4,12(s0)
    readIndex = rbType->readIndex;
2300584a:	4404                	lw	s1,8(s0)
    writeIndex = rbType->writeIndex;
2300584c:	01042903          	lw	s2,16(s0)
    size = rbType->size;
23005850:	01442983          	lw	s3,20(s0)
    if(rbType->unlock != NULL){
23005854:	c391                	beqz	a5,23005858 <Ring_Buffer_Get_Length+0x30>
        rbType->unlock();
23005856:	9782                	jalr	a5
    }
    
    if(readMirror == writeMirror){
        return writeIndex - readIndex;
23005858:	40990533          	sub	a0,s2,s1
    if(readMirror == writeMirror){
2300585c:	014a8563          	beq	s5,s4,23005866 <Ring_Buffer_Get_Length+0x3e>
    }else{
        return size - (readIndex - writeIndex);
23005860:	01390533          	add	a0,s2,s3
23005864:	8d05                	sub	a0,a0,s1
    }
}
23005866:	40f2                	lw	ra,28(sp)
23005868:	4462                	lw	s0,24(sp)
2300586a:	44d2                	lw	s1,20(sp)
2300586c:	4942                	lw	s2,16(sp)
2300586e:	49b2                	lw	s3,12(sp)
23005870:	4a22                	lw	s4,8(sp)
23005872:	4a92                	lw	s5,4(sp)
23005874:	6105                	addi	sp,sp,32
23005876:	8082                	ret

23005878 <Ring_Buffer_Read_Callback>:
{
23005878:	1101                	addi	sp,sp,-32
2300587a:	c64e                	sw	s3,12(sp)
2300587c:	89b2                	mv	s3,a2
2300587e:	cc22                	sw	s0,24(sp)
23005880:	c84a                	sw	s2,16(sp)
23005882:	c452                	sw	s4,8(sp)
23005884:	ce06                	sw	ra,28(sp)
23005886:	ca26                	sw	s1,20(sp)
23005888:	c256                	sw	s5,4(sp)
2300588a:	842a                	mv	s0,a0
2300588c:	892e                	mv	s2,a1
2300588e:	8a36                	mv	s4,a3
    uint32_t size = Ring_Buffer_Get_Length(rbType);
23005890:	3f61                	jal	23005828 <Ring_Buffer_Get_Length>
    if(readCb == NULL){
23005892:	00099d63          	bnez	s3,230058ac <Ring_Buffer_Read_Callback+0x34>
        return 0;
23005896:	4481                	li	s1,0
}
23005898:	40f2                	lw	ra,28(sp)
2300589a:	4462                	lw	s0,24(sp)
2300589c:	8526                	mv	a0,s1
2300589e:	4942                	lw	s2,16(sp)
230058a0:	44d2                	lw	s1,20(sp)
230058a2:	49b2                	lw	s3,12(sp)
230058a4:	4a22                	lw	s4,8(sp)
230058a6:	4a92                	lw	s5,4(sp)
230058a8:	6105                	addi	sp,sp,32
230058aa:	8082                	ret
    if(rbType->lock != NULL){
230058ac:	4c1c                	lw	a5,24(s0)
230058ae:	84aa                	mv	s1,a0
230058b0:	c391                	beqz	a5,230058b4 <Ring_Buffer_Read_Callback+0x3c>
        rbType->lock();
230058b2:	9782                	jalr	a5
    if(!size){
230058b4:	e489                	bnez	s1,230058be <Ring_Buffer_Read_Callback+0x46>
        if(rbType->unlock != NULL){
230058b6:	4c5c                	lw	a5,28(s0)
230058b8:	dff9                	beqz	a5,23005896 <Ring_Buffer_Read_Callback+0x1e>
        rbType->unlock();
230058ba:	9782                	jalr	a5
230058bc:	bff1                	j	23005898 <Ring_Buffer_Read_Callback+0x20>
    if(size < length){
230058be:	00997363          	bgeu	s2,s1,230058c4 <Ring_Buffer_Read_Callback+0x4c>
230058c2:	84ca                	mv	s1,s2
    size = rbType->size - rbType->readIndex;
230058c4:	00842903          	lw	s2,8(s0)
230058c8:	01442a83          	lw	s5,20(s0)
230058cc:	400c                	lw	a1,0(s0)
230058ce:	412a8633          	sub	a2,s5,s2
    if(size > length){
230058d2:	95ca                	add	a1,a1,s2
230058d4:	00c4fb63          	bgeu	s1,a2,230058ea <Ring_Buffer_Read_Callback+0x72>
        readCb(parameter,&rbType->pointer[rbType->readIndex],length);
230058d8:	8626                	mv	a2,s1
230058da:	8552                	mv	a0,s4
230058dc:	9982                	jalr	s3
        rbType->readIndex += length;
230058de:	441c                	lw	a5,8(s0)
230058e0:	97a6                	add	a5,a5,s1
230058e2:	c41c                	sw	a5,8(s0)
    if(rbType->unlock != NULL){
230058e4:	4c5c                	lw	a5,28(s0)
230058e6:	fbf1                	bnez	a5,230058ba <Ring_Buffer_Read_Callback+0x42>
230058e8:	bf45                	j	23005898 <Ring_Buffer_Read_Callback+0x20>
        readCb(parameter,&rbType->pointer[rbType->readIndex],size);
230058ea:	8552                	mv	a0,s4
230058ec:	9982                	jalr	s3
        readCb(parameter,&rbType->pointer[0],length-size);
230058ee:	41590933          	sub	s2,s2,s5
230058f2:	400c                	lw	a1,0(s0)
230058f4:	9926                	add	s2,s2,s1
230058f6:	864a                	mv	a2,s2
230058f8:	8552                	mv	a0,s4
230058fa:	9982                	jalr	s3
        rbType->readIndex = length-size;
230058fc:	01242423          	sw	s2,8(s0)
        rbType->readMirror = ~rbType->readMirror;
23005900:	00444783          	lbu	a5,4(s0)
23005904:	fff7c793          	not	a5,a5
23005908:	00f40223          	sb	a5,4(s0)
2300590c:	bfe1                	j	230058e4 <Ring_Buffer_Read_Callback+0x6c>

2300590e <Ring_Buffer_Read>:
{
2300590e:	1101                	addi	sp,sp,-32
23005910:	c62e                	sw	a1,12(sp)
23005912:	85b2                	mv	a1,a2
    return Ring_Buffer_Read_Callback(rbType,length,Ring_Buffer_Read_Copy,&data);
23005914:	23005637          	lui	a2,0x23005
23005918:	0074                	addi	a3,sp,12
2300591a:	7e660613          	addi	a2,a2,2022 # 230057e6 <Ring_Buffer_Read_Copy>
{
2300591e:	ce06                	sw	ra,28(sp)
    return Ring_Buffer_Read_Callback(rbType,length,Ring_Buffer_Read_Copy,&data);
23005920:	3fa1                	jal	23005878 <Ring_Buffer_Read_Callback>
}
23005922:	40f2                	lw	ra,28(sp)
23005924:	6105                	addi	sp,sp,32
23005926:	8082                	ret

23005928 <Ring_Buffer_Get_Empty_Length>:
 *
 * @return Length of space remained
 *
*******************************************************************************/
uint32_t Ring_Buffer_Get_Empty_Length(Ring_Buffer_Type* rbType)
{
23005928:	1141                	addi	sp,sp,-16
2300592a:	c422                	sw	s0,8(sp)
    return (rbType->size - Ring_Buffer_Get_Length(rbType));
2300592c:	4940                	lw	s0,20(a0)
{
2300592e:	c606                	sw	ra,12(sp)
    return (rbType->size - Ring_Buffer_Get_Length(rbType));
23005930:	ef9ff0ef          	jal	ra,23005828 <Ring_Buffer_Get_Length>
}
23005934:	40a40533          	sub	a0,s0,a0
23005938:	40b2                	lw	ra,12(sp)
2300593a:	4422                	lw	s0,8(sp)
2300593c:	0141                	addi	sp,sp,16
2300593e:	8082                	ret

23005940 <Ring_Buffer_Write_Callback>:
{
23005940:	1101                	addi	sp,sp,-32
23005942:	c64e                	sw	s3,12(sp)
23005944:	89b2                	mv	s3,a2
23005946:	cc22                	sw	s0,24(sp)
23005948:	c84a                	sw	s2,16(sp)
2300594a:	c452                	sw	s4,8(sp)
2300594c:	ce06                	sw	ra,28(sp)
2300594e:	ca26                	sw	s1,20(sp)
23005950:	c256                	sw	s5,4(sp)
23005952:	842a                	mv	s0,a0
23005954:	892e                	mv	s2,a1
23005956:	8a36                	mv	s4,a3
    uint32_t sizeRemained = Ring_Buffer_Get_Empty_Length(rbType);
23005958:	3fc1                	jal	23005928 <Ring_Buffer_Get_Empty_Length>
    if(writeCb == NULL){
2300595a:	00099d63          	bnez	s3,23005974 <Ring_Buffer_Write_Callback+0x34>
        return 0;
2300595e:	4481                	li	s1,0
}
23005960:	40f2                	lw	ra,28(sp)
23005962:	4462                	lw	s0,24(sp)
23005964:	8526                	mv	a0,s1
23005966:	4942                	lw	s2,16(sp)
23005968:	44d2                	lw	s1,20(sp)
2300596a:	49b2                	lw	s3,12(sp)
2300596c:	4a22                	lw	s4,8(sp)
2300596e:	4a92                	lw	s5,4(sp)
23005970:	6105                	addi	sp,sp,32
23005972:	8082                	ret
    if(rbType->lock != NULL){
23005974:	4c1c                	lw	a5,24(s0)
23005976:	84aa                	mv	s1,a0
23005978:	c391                	beqz	a5,2300597c <Ring_Buffer_Write_Callback+0x3c>
        rbType->lock();
2300597a:	9782                	jalr	a5
    if(sizeRemained == 0){
2300597c:	e489                	bnez	s1,23005986 <Ring_Buffer_Write_Callback+0x46>
        if(rbType->unlock != NULL){
2300597e:	4c5c                	lw	a5,28(s0)
23005980:	dff9                	beqz	a5,2300595e <Ring_Buffer_Write_Callback+0x1e>
        rbType->unlock();
23005982:	9782                	jalr	a5
23005984:	bff1                	j	23005960 <Ring_Buffer_Write_Callback+0x20>
    if(length > sizeRemained){
23005986:	00997363          	bgeu	s2,s1,2300598c <Ring_Buffer_Write_Callback+0x4c>
2300598a:	84ca                	mv	s1,s2
    sizeRemained = rbType->size - rbType->writeIndex;
2300598c:	01042903          	lw	s2,16(s0)
23005990:	01442a83          	lw	s5,20(s0)
23005994:	400c                	lw	a1,0(s0)
23005996:	412a8633          	sub	a2,s5,s2
    if(sizeRemained > length){
2300599a:	95ca                	add	a1,a1,s2
2300599c:	00c4fb63          	bgeu	s1,a2,230059b2 <Ring_Buffer_Write_Callback+0x72>
        writeCb(parameter,&rbType->pointer[rbType->writeIndex],length);
230059a0:	8626                	mv	a2,s1
230059a2:	8552                	mv	a0,s4
230059a4:	9982                	jalr	s3
        rbType->writeIndex += length;
230059a6:	481c                	lw	a5,16(s0)
230059a8:	97a6                	add	a5,a5,s1
230059aa:	c81c                	sw	a5,16(s0)
    if(rbType->unlock != NULL){
230059ac:	4c5c                	lw	a5,28(s0)
230059ae:	fbf1                	bnez	a5,23005982 <Ring_Buffer_Write_Callback+0x42>
230059b0:	bf45                	j	23005960 <Ring_Buffer_Write_Callback+0x20>
        writeCb(parameter,&rbType->pointer[rbType->writeIndex],sizeRemained);
230059b2:	8552                	mv	a0,s4
230059b4:	9982                	jalr	s3
        writeCb(parameter,&rbType->pointer[0],length-sizeRemained);
230059b6:	41590933          	sub	s2,s2,s5
230059ba:	400c                	lw	a1,0(s0)
230059bc:	9926                	add	s2,s2,s1
230059be:	864a                	mv	a2,s2
230059c0:	8552                	mv	a0,s4
230059c2:	9982                	jalr	s3
        rbType->writeIndex = length-sizeRemained;
230059c4:	01242823          	sw	s2,16(s0)
        rbType->writeMirror = ~rbType->writeMirror;
230059c8:	00c44783          	lbu	a5,12(s0)
230059cc:	fff7c793          	not	a5,a5
230059d0:	00f40623          	sb	a5,12(s0)
230059d4:	bfe1                	j	230059ac <Ring_Buffer_Write_Callback+0x6c>

230059d6 <Ring_Buffer_Write>:
{
230059d6:	1101                	addi	sp,sp,-32
230059d8:	c62e                	sw	a1,12(sp)
230059da:	85b2                	mv	a1,a2
    return Ring_Buffer_Write_Callback(rbType,length,Ring_Buffer_Write_Copy,&data);
230059dc:	23005637          	lui	a2,0x23005
230059e0:	0074                	addi	a3,sp,12
230059e2:	7be60613          	addi	a2,a2,1982 # 230057be <Ring_Buffer_Write_Copy>
{
230059e6:	ce06                	sw	ra,28(sp)
    return Ring_Buffer_Write_Callback(rbType,length,Ring_Buffer_Write_Copy,&data);
230059e8:	3fa1                	jal	23005940 <Ring_Buffer_Write_Callback>
}
230059ea:	40f2                	lw	ra,28(sp)
230059ec:	6105                	addi	sp,sp,32
230059ee:	8082                	ret

230059f0 <Ring_Buffer_Write_Byte>:
{
230059f0:	1101                	addi	sp,sp,-32
    if(rbType->lock != NULL){
230059f2:	4d1c                	lw	a5,24(a0)
{
230059f4:	cc22                	sw	s0,24(sp)
230059f6:	ca26                	sw	s1,20(sp)
230059f8:	ce06                	sw	ra,28(sp)
230059fa:	842a                	mv	s0,a0
230059fc:	84ae                	mv	s1,a1
    if(rbType->lock != NULL){
230059fe:	c391                	beqz	a5,23005a02 <Ring_Buffer_Write_Byte+0x12>
        rbType->lock();
23005a00:	9782                	jalr	a5
    if(!Ring_Buffer_Get_Empty_Length(rbType)){
23005a02:	8522                	mv	a0,s0
23005a04:	f25ff0ef          	jal	ra,23005928 <Ring_Buffer_Get_Empty_Length>
23005a08:	e919                	bnez	a0,23005a1e <Ring_Buffer_Write_Byte+0x2e>
        if(rbType->unlock != NULL){
23005a0a:	4c5c                	lw	a5,28(s0)
23005a0c:	c781                	beqz	a5,23005a14 <Ring_Buffer_Write_Byte+0x24>
23005a0e:	c62a                	sw	a0,12(sp)
            rbType->unlock();
23005a10:	9782                	jalr	a5
23005a12:	4532                	lw	a0,12(sp)
}
23005a14:	40f2                	lw	ra,28(sp)
23005a16:	4462                	lw	s0,24(sp)
23005a18:	44d2                	lw	s1,20(sp)
23005a1a:	6105                	addi	sp,sp,32
23005a1c:	8082                	ret
    rbType->pointer[rbType->writeIndex] = data;
23005a1e:	4818                	lw	a4,16(s0)
23005a20:	401c                	lw	a5,0(s0)
23005a22:	97ba                	add	a5,a5,a4
23005a24:	00978023          	sb	s1,0(a5)
    if(rbType->writeIndex != (rbType->size-1)){
23005a28:	4858                	lw	a4,20(s0)
23005a2a:	481c                	lw	a5,16(s0)
23005a2c:	177d                	addi	a4,a4,-1
23005a2e:	00e78a63          	beq	a5,a4,23005a42 <Ring_Buffer_Write_Byte+0x52>
        rbType->writeIndex++;
23005a32:	0785                	addi	a5,a5,1
23005a34:	c81c                	sw	a5,16(s0)
    if(rbType->unlock != NULL){
23005a36:	4c5c                	lw	a5,28(s0)
    return 1;
23005a38:	4505                	li	a0,1
    if(rbType->unlock != NULL){
23005a3a:	dfe9                	beqz	a5,23005a14 <Ring_Buffer_Write_Byte+0x24>
        rbType->unlock();
23005a3c:	9782                	jalr	a5
    return 1;
23005a3e:	4505                	li	a0,1
23005a40:	bfd1                	j	23005a14 <Ring_Buffer_Write_Byte+0x24>
        rbType->writeMirror = ~rbType->writeMirror;
23005a42:	00c44783          	lbu	a5,12(s0)
        rbType->writeIndex = 0;
23005a46:	00042823          	sw	zero,16(s0)
        rbType->writeMirror = ~rbType->writeMirror;
23005a4a:	fff7c793          	not	a5,a5
23005a4e:	00f40623          	sb	a5,12(s0)
23005a52:	b7d5                	j	23005a36 <Ring_Buffer_Write_Byte+0x46>

23005a54 <led_pins>:
23005a54:	0009 0000 0011 0000 7065 6425 7720 6961     ........ep%d wai
23005a64:	2074 7266 6565 7420 6d69 6f65 7475 0a0d     t free timeout..
23005a74:	0000 0000 0c16 2300 0c1e 2300 0c24 2300     .......#...#$..#
23005a84:	0c44 2300 0c44 2300 0c44 2300 0c44 2300     D..#D..#D..#D..#
23005a94:	0c44 2300 0c2a 2300 0c30 2300 0c36 2300     D..#*..#0..#6..#
23005aa4:	0c3c 2300 0c40 2300 7375 0062 6175 7472     <..#@..#usb.uart
23005ab4:	0031 0000 6863 0032 4652 0a0d 0000 0000     1...ch2.RF......
23005ac4:	5452 0d4f 000a 0000 766f 0a0d 0000 0000     RTO.....ov......
23005ad4:	5d18 2201 5e6c 2201 5e7e 2201 5eb4 2201     .]."l^."~^.".^."
23005ae4:	5fea 2201 601e 2201 60ea 2201 6096 2201     ._.".`.".`.".`."
23005af4:	60fe 2201 618a 2201 60e4 2201 5f42 2201     .`.".a.".`."B_."

23005b04 <ftdi_eeprom_info>:
23005b04:	0800 0403 6010 0500 3280 0000 0200 1096     .....`...2......
23005b14:	1aa6 0000 0046 0310 004f 0070 0065 006e     ....F...O.p.e.n.
23005b24:	002d 0045 0043 031a 0055 0053 0042 0020     -.E.C...U.S.B. .
23005b34:	0044 0065 0062 0075 0067 0067 0065 0072     D.e.b.u.g.g.e.r.
	...
23005b80:	0000 1027 7964 616e 696d 2063 656d 6f6d     ..'.dynamic memo
23005b90:	7972 6920 696e 2074 7265 6f72 0d72 000a     ry init error...
23005ba0:	6564 7562 5f67 6f6c 0067 0000               debug_log...

23005bac <af_pin_table>:
23005bac:	0000 00ff 0001 00ff 0002 00ff 0003 00ff     ................
23005bbc:	0004 00ff 0005 00ff 0006 00ff 0007 000a     ................
23005bcc:	0008 000a 0009 00ff 000a 00ff 000b 00ff     ................
23005bdc:	000c 00ff 000d 00ff 000e 0072 000f 00ff     ..........r.....
23005bec:	0010 00ff 0011 00ff 0012 00ff 0013 00ff     ................
23005bfc:	0014 00ff 0015 00ff 0016 00ff 0017 00ff     ................
23005c0c:	0018 00ff 0019 00ff 001a 00ff 001b 00ff     ................
23005c1c:	001c 00ff 001d 00ff 001e 00ff 001f 00ff     ................
23005c2c:	0020 0073 0021 00ff 0022 00ff 0023 0076      .s.!..."...#.v.
23005c3c:	0024 0077 0025 00ff 5f20 5f5f 5f5f 5f20     $.w.%... _____ _
23005c4c:	5f5f 5f5f 5f5f 5f5f 5f5f 5f20 5f5f 5f5f     __________ _____
23005c5c:	5f20 5f5f 5f5f 5f5f 5f5f 5f5f 0d20 000a      ___________ ...
23005c6c:	202f 5f20 5f5f 5f7c 2020 5f20 207c 5f5f     /  ___|_   _| __
23005c7c:	205f 205c 5f20 5f5f 207c 5f20 5f5f 207c     _ \  ___|  ___| 
23005c8c:	5f20 2020 205c 0a0d 0000 0000 205c 2d60      _  \ ......\ `-
23005c9c:	2e2d 2020 207c 207c 207c 5f7c 202f 202f     -.  | | | |_/ / 
23005cac:	5f7c 205f 207c 5f7c 205f 207c 207c 207c     |__ | |__ | | | 
23005cbc:	0d7c 000a 6020 2d2d 202e 205c 207c 207c     |... `--. \ | | 
23005ccc:	207c 5f20 2f5f 207c 5f20 7c5f 207c 5f20     |  __/|  __||  _
23005cdc:	7c5f 207c 207c 207c 0d7c 000a 5c2f 5f5f     _|| | | |.../\__
23005cec:	202f 5f2f 207c 5f7c 207c 207c 2020 207c     / /_| |_| |   | 
23005cfc:	5f7c 5f5f 207c 5f7c 5f5f 207c 2f7c 2f20     |___| |___| |/ /
23005d0c:	0d20 000a 5f5c 5f5f 2f5f 5c20 5f5f 2f5f      ...\____/ \___/
23005d1c:	5f5c 207c 2020 5f5c 5f5f 2f5f 5f5c 5f5f     \_|   \____/\___
23005d2c:	2f5f 5f7c 5f5f 202f 0d20 000a 754a 206e     _/|___/  ...Jun 
23005d3c:	3431 3220 3230 0031 3231 313a 3a38 3232     14 2021.12:18:22
23005d4c:	0000 0000 7542 6c69 3a64 7325 252c 0d73     ....Build:%s,%s.
23005d5c:	000a 0000 6f43 7970 6972 6867 2074 6328     ....Copyright (c
23005d6c:	2029 3032 3132 5320 7069 6565 2064 6574     ) 2021 Sipeed te
23005d7c:	6d61 0a0d 0000 0000 1478 2300 149a 2300     am......x..#...#
23005d8c:	1496 2300 1496 2300 1496 2300 14ba 2300     ...#...#...#...#
23005d9c:	1496 2300 1496 2300 1496 2300 1496 2300     ...#...#...#...#
23005dac:	1496 2300 1496 2300 1496 2300 1496 2300     ...#...#...#...#
23005dbc:	1496 2300 14e4 2300 14f4 2300 14fe 2300     ...#...#...#...#
23005dcc:	14da 2300 1958 2300 1974 2300 1978 2300     ...#X..#t..#x..#
23005ddc:	197e 2300 1984 2300 198a 2300 4157 4e52     ~..#...#...#WARN
23005dec:	4e49 3a47 4320 656c 7261 4720 4950 204f     ING: Clear GPIO 
23005dfc:	6e69 6574 7272 7075 2074 7473 7461 7375     interrupt status
23005e0c:	6620 6961 2e6c 0a0d 0000 0000 1c16 2300      fail..........#
23005e1c:	1c5c 2300 1c52 2300 1d1e 2300 1c9e 2300     \..#R..#...#...#
23005e2c:	1caa 2300 1c52 2300 1d2a 2300 1d2e 2300     ...#R..#*..#...#
23005e3c:	1d32 2300 1d4a 2300 1d60 2300 1d78 2300     2..#J..#`..#x..#
23005e4c:	1c52 2300 1c52 2300 1d90 2300 1da8 2300     R..#R..#...#...#
23005e5c:	1eee 2300 1efe 2300 1efe 2300 1efe 2300     ...#...#...#...#
23005e6c:	1efe 2300 1efe 2300 1efe 2300 1fa8 2300     ...#...#...#...#
23005e7c:	1fae 2300 1efe 2300 1efe 2300 1efe 2300     ...#...#...#...#
23005e8c:	1efe 2300 1efe 2300 1efe 2300 1f22 2300     ...#...#...#"..#
23005e9c:	1f2c 2300 1f38 2300 1f3c 2300 1f5c 2300     ,..#8..#<..#\..#
23005eac:	1efe 2300 1efe 2300 1efe 2300 1f7c 2300     ...#...#...#|..#
23005ebc:	1f94 2300 1efe 2300 1efe 2300 1efe 2300     ...#...#...#...#
23005ecc:	1efe 2300 1efe 2300 1efe 2300 1f9e 2300     ...#...#...#...#
23005edc:	1fb4 2300 1fc0 2300 7257 6e6f 2067 6e65     ...#...#Wrong en
23005eec:	7064 696f 746e 6420 7269 6365 6974 6e6f     dpoint direction
23005efc:	0a0d 0000 6f4e 2074 6e65 6261 656c 2064     ....Not enabled 
23005f0c:	6e65 7064 696f 746e 0a0d 0000 6164 6174     endpoint....data
23005f1c:	6920 2073 756e 6c6c 0a0d 0000 6f4c 7473      is null....Lost
23005f2c:	3320 5320 464f 0d73 000a 0000 2aa8 2300      3 SOFs......*.#
23005f3c:	2ab6 2300 2ac4 2300 2ad2 2300 2ae0 2300     .*.#.*.#.*.#.*.#
23005f4c:	2aee 2300 2afc 2300 2b0a 2300 2b3a 2300     .*.#.*.#.+.#:+.#
23005f5c:	2b3a 2300 2b1e 2300 7845 6563 7470 6f69     :+.#.+.#Exceptio
23005f6c:	206e 6873 756f 646c 6e20 746f 6220 2065     n should not be 
23005f7c:	6568 6572 0a0d 0000 6e49 6574 7272 7075     here....Interrup
23005f8c:	2074 756e 3a6d 6425 4920 5152 6148 646e     t num:%d IRQHand
23005f9c:	656c 2072 6f6e 2074 6e69 7473 6c61 656c     ler not installe
23005fac:	0d64 000a 6550 6972 6870 7265 6c61 4920     d...Peripheral I
23005fbc:	746e 7265 7572 7470 6e20 6d75 253a 2064     nterrupt num:%d 
23005fcc:	0a0d 0000 6e55 7865 6570 7463 6465 6920     ....Unexpected i
23005fdc:	746e 7265 7572 7470 6e20 6d75 253a 0d64     nterrupt num:%d.
23005fec:	000a 0000 7254 7061 485f 6e61 6c64 7265     ....Trap_Handler
23005ffc:	0a0d 0000 636d 7561 6573 253d 3830 0d78     ....mcause=%08x.
2300600c:	000a 0000 656d 6370 253a 3830 0d78 000a     ....mepc:%08x...
2300601c:	746d 6176 3a6c 3025 7838 0a0d 0000 0000     mtval:%08x......
2300602c:	6e49 7473 7572 7463 6f69 206e 6361 6563     Instruction acce
2300603c:	7373 6620 7561 746c 0a0d 0000 6c49 656c     ss fault....Ille
2300604c:	6167 206c 6e69 7473 7572 7463 6f69 0d6e     gal instruction.
2300605c:	000a 0000 7242 6165 706b 696f 746e 0a0d     ....Breakpoint..
2300606c:	0000 0000 6f4c 6461 6120 6464 6572 7373     ....Load address
2300607c:	6d20 7369 6c61 6769 656e 0d64 000a 0000      misaligned.....
2300608c:	6f4c 6461 6120 6363 7365 2073 6166 6c75     Load access faul
2300609c:	0d74 000a 7453 726f 2f65 4d41 204f 6461     t...Store/AMO ad
230060ac:	7264 7365 2073 696d 6173 696c 6e67 6465     dress misaligned
230060bc:	0a0d 0000 7453 726f 2f65 4d41 204f 6361     ....Store/AMO ac
230060cc:	6563 7373 6620 7561 746c 0a0d 0000 0000     cess fault......
230060dc:	6e45 6976 6f72 6d6e 6e65 2074 6163 6c6c     Environment call
230060ec:	6620 6f72 206d 2d55 6f6d 6564 0a0d 0000      from U-mode....
230060fc:	6e45 6976 6f72 6d6e 6e65 2074 6163 6c6c     Environment call
2300610c:	6620 6f72 206d 2d4d 6f6d 6564 0a0d 0000      from M-mode....
2300611c:	6143 7375 2065 756e 3d6d 6425 0a0d 0000     Cause num=%d....

2300612c <uartAddr>:
2300612c:	a000 4000 a100 4000 378a 2300 379a 2300     ...@...@.7.#.7.#
2300613c:	37aa 2300 37ba 2300 37ca 2300 37da 2300     .7.#.7.#.7.#.7.#
2300614c:	37ea 2300 383e 2300 3850 2300 3862 2300     .7.#>8.#P8.#b8.#
2300615c:	3874 2300 3886 2300 3898 2300 38aa 2300     t8.#.8.#.8.#.8.#
2300616c:	38ee 2300 38fa 2300 3904 2300 390e 2300     .8.#.8.#.9.#.9.#
2300617c:	3918 2300 3922 2300 392c 2300 396e 2300     .9.#"9.#,9.#n9.#
2300618c:	397c 2300 398a 2300 3998 2300 39a6 2300     |9.#.9.#.9.#.9.#
2300619c:	39b4 2300 39c2 2300 39f6 2300 3a04 2300     .9.#.9.#.9.#.:.#
230061ac:	3a10 2300 3a1c 2300 3a28 2300 3a34 2300     .:.#.:.#(:.#4:.#
230061bc:	3a40 2300 3a88 2300 3a9a 2300 3aac 2300     @:.#.:.#.:.#.:.#
230061cc:	3abe 2300 3ad0 2300 3ae2 2300 3af4 2300     .:.#.:.#.:.#.:.#
230061dc:	3ba4 2300 3b5c 2300 3b60 2300 3ba2 2300     .;.#\;.#`;.#.;.#
230061ec:	3b60 2300 3ba2 2300 3b60 2300 3b82 2300     `;.#.;.#`;.#.;.#
230061fc:	3ba6 2300 3bb0 2300 3bba 2300 3bc4 2300     .;.#.;.#.;.#.;.#
2300620c:	3bce 2300 3bd8 2300 3cf6 2300 3d16 2300     .;.#.;.#.<.#.=.#
2300621c:	3d34 2300 3d52 2300 3d70 2300 3d8e 2300     4=.#R=.#p=.#.=.#
2300622c:	3dac 2300 3df0 2300 3e00 2300 3e0e 2300     .=.#.=.#.>.#.>.#
2300623c:	3e1c 2300 3e2a 2300 3e38 2300 3e46 2300     .>.#*>.#8>.#F>.#
2300624c:	3e54 2300 3e7c 2300 3e84 2300 3e8c 2300     T>.#|>.#.>.#.>.#
2300625c:	3e94 2300 3e9c 2300 3ea4 2300 3eac 2300     .>.#.>.#.>.#.>.#
2300626c:	3eb4 2300 3edc 2300 3eec 2300 3efa 2300     .>.#.>.#.>.#.>.#
2300627c:	3f08 2300 3f16 2300 3f24 2300 3f32 2300     .?.#.?.#$?.#2?.#
2300628c:	3f40 2300 3f68 2300 3f70 2300 3f78 2300     @?.#h?.#p?.#x?.#
2300629c:	3f80 2300 3f88 2300 3f90 2300 3f98 2300     .?.#.?.#.?.#.?.#
230062ac:	3fa0 2300 3fbe 2300 3fcc 2300 3fd6 2300     .?.#.?.#.?.#.?.#
230062bc:	3fe0 2300 3fea 2300 3ff4 2300 3ffe 2300     .?.#.?.#.?.#.?.#
230062cc:	4008 2300 402c 2300 403c 2300 4046 2300     .@.#,@.#<@.#F@.#
230062dc:	4050 2300 405a 2300 4064 2300 406e 2300     P@.#Z@.#d@.#n@.#
230062ec:	4078 2300 4412 2300 43fa 2300 4412 2300     x@.#.D.#.C.#.D.#
230062fc:	4412 2300 4412 2300 4412 2300 4412 2300     .D.#.D.#.D.#.D.#
2300630c:	4412 2300 4412 2300 4412 2300 4412 2300     .D.#.D.#.D.#.D.#
2300631c:	4412 2300 4412 2300 4488 2300 451a 2300     .D.#.D.#.D.#.E.#
2300632c:	4530 2300 4598 2300 45bc 2300 46b0 2300     0E.#.E.#.E.#.F.#
2300633c:	46ba 2300 47fa 2300 46ce 2300 47fa 2300     .F.#.G.#.F.#.G.#
2300634c:	46de 2300 46e8 2300 4628 2300 477c 2300     .F.#.F.#(F.#|G.#
2300635c:	4786 2300 4688 2300 4688 2300 46b0 2300     .G.#.F.#.F.#.F.#
2300636c:	4628 2300 48b2 2300 4628 2300 48b2 2300     (F.#.H.#(F.#.H.#
2300637c:	48b2 2300 48b2 2300 48b2 2300 48b2 2300     .H.#.H.#.H.#.H.#
2300638c:	48b2 2300 4836 2300 483c 2300 6552 6461     .H.#6H.#<H.#Read
2300639c:	5320 7465 7075 5020 6361 656b 2074 6166      Setup Packet fa
230063ac:	6c69 6465 0a0d 0000 6552 7571 7365 2074     iled....Request 
230063bc:	7562 6666 7265 7420 6f6f 7320 616d 6c6c     buffer too small
230063cc:	0a0d 0000 7375 6462 735f 7465 7075 725f     ....usbd_setup_r
230063dc:	7165 6575 7473 685f 6e61 6c64 7265 6620     equest_handler f
230063ec:	6961 656c 0d64 000a 6552 6461 4420 5441     ailed...Read DAT
230063fc:	2041 6150 6b63 7465 6620 6961 656c 0d64     A Packet failed.
2300640c:	000a 0000 7375 6462 735f 7465 7075 725f     ....usbd_setup_r
2300641c:	7165 6575 7473 685f 6e61 6c64 7265 2031     equest_handler1 
2300642c:	6166 6c69 6465 0a0d 0000 0000 7065 5f30     failed......ep0_
2300643c:	6164 6174 625f 6675 725f 7365 6469 6575     data_buf_residue
2300644c:	6920 2073 6f6e 2074 657a 6f72 0a0d 0000      is not zero....
2300645c:	5355 2042 6e75 6e6b 776f 206e 7665 6e65     USB unknown even
2300646c:	3a74 2520 0064 0000 6553 7574 3a70 6220     t: %d...Setup: b
2300647c:	526d 7165 6575 7473 7954 6570 3020 2578     mRequestType 0x%
2300648c:	3230 2c78 6220 6552 7571 7365 2074 7830     02x, bRequest 0x
2300649c:	3025 7832 202c 5677 6c61 6575 3020 2578     %02x, wValue 0x%
230064ac:	3430 2c78 7720 6e49 6564 2078 7830 3025     04x, wIndex 0x%0
230064bc:	7834 202c 4c77 6e65 7467 2068 7830 3025     4x, wLength 0x%0
230064cc:	7834 0a0d 0000 0000 704f 6e65 6520 646e     4x......Open end
230064dc:	6f70 6e69 3a74 7830 7825 7420 7079 3a65     point:0x%x type:
230064ec:	7525 6d20 7370 253a 0d75 000a 534d 4f20     %u mps:%u...MS O
230064fc:	2053 6544 6373 6972 7470 726f 7320 7274     S Descriptor str
2300650c:	6e69 2067 6572 6461 0a0d 0000 4f42 2053     ing read....BOS 
2300651c:	6564 6373 6972 7470 726f 7320 7274 6e69     descriptor strin
2300652c:	2067 6572 6461 0a0d 0000 0000 6544 6976     g read......Devi
2300653c:	6563 6e20 746f 6320 6e6f 6966 7567 6572     ce not configure
2300654c:	2064 202d 6e69 6176 696c 2064 6f63 666e     d - invalid conf
2300655c:	6769 7275 7461 6f69 0d6e 000a 6c49 656c     iguration...Ille
2300656c:	6167 206c 6564 6976 6563 7220 7165 3020     gal device req 0
2300657c:	2578 3230 0d78 000a 6c43 736f 2065 6e65     x%02x...Close en
2300658c:	7064 696f 746e 303a 2578 2078 7974 6570     dpoint:0x%x type
2300659c:	253a 0d75 000a 0000 6c49 656c 6167 206c     :%u.....Illegal 
230065ac:	6e69 6574 6672 6361 2065 6572 2071 7830     interface req 0x
230065bc:	3025 7832 0a0d 0000 7065 253a 2078 6c63     %02x....ep:%x cl
230065cc:	6165 2072 6168 746c 0a0d 0000 7065 253a     ear halt....ep:%
230065dc:	2078 6573 2074 6168 746c 0a0d 0000 0000     x set halt......
230065ec:	6c49 656c 6167 206c 7065 7220 7165 3020     Illegal ep req 0
230065fc:	2578 3230 0d78 000a 6148 646e 656c 2072     x%02x...Handler 
2300660c:	7245 6f72 2072 6425 0a0d 0000 6148 646e     Error %d....Hand
2300661c:	656c 4320 6d6f 6170 2074 4449 0a0d 0000     le Compat ID....
2300662c:	6564 6373 6972 7470 726f 3c20 7974 6570     descriptor <type
2300663c:	253a 2c78 6e69 6564 3a78 7825 203e 6f6e     :%x,index:%x> no
2300664c:	2074 6f66 6e75 2164 0a0d 0000 4d38 2300     t found!....8M.#
2300665c:	4d50 2300 4d84 2300 4dc6 2300 4dfa 2300     PM.#.M.#.M.#.M.#
2300666c:	4d72 2300 52d6 2300 52d6 2300 4d78 2300     rM.#.R.#.R.#xM.#
2300667c:	52d6 2300 52d6 2300 52d6 2300 4d6c 2300     .R.#.R.#.R.#lM.#
2300668c:	52d6 2300 52d6 2300 52d6 2300 4d66 2300     .R.#.R.#.R.#fM.#
2300669c:	52d6 2300 4db2 2300 52d6 2300 52d6 2300     .R.#.M.#.R.#.R.#
230066ac:	4d7e 2300                                   ~M.#

230066b0 <lcdigits.1537>:
230066b0:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
230066c0:	0000 0000                                   ....

230066c4 <ucdigits.1538>:
230066c4:	3130 3332 3534 3736 3938 4241 4443 4645     0123456789ABCDEF
230066d4:	0000 0000 6e28 6c75 296c 0000               ....(null)..

230066e0 <__clz_tab>:
230066e0:	0100 0202 0303 0303 0404 0404 0404 0404     ................
230066f0:	0505 0505 0505 0505 0505 0505 0505 0505     ................
23006700:	0606 0606 0606 0606 0606 0606 0606 0606     ................
23006710:	0606 0606 0606 0606 0606 0606 0606 0606     ................
23006720:	0707 0707 0707 0707 0707 0707 0707 0707     ................
23006730:	0707 0707 0707 0707 0707 0707 0707 0707     ................
23006740:	0707 0707 0707 0707 0707 0707 0707 0707     ................
23006750:	0707 0707 0707 0707 0707 0707 0707 0707     ................
23006760:	0808 0808 0808 0808 0808 0808 0808 0808     ................
23006770:	0808 0808 0808 0808 0808 0808 0808 0808     ................
23006780:	0808 0808 0808 0808 0808 0808 0808 0808     ................
23006790:	0808 0808 0808 0808 0808 0808 0808 0808     ................
230067a0:	0808 0808 0808 0808 0808 0808 0808 0808     ................
230067b0:	0808 0808 0808 0808 0808 0808 0808 0808     ................
230067c0:	0808 0808 0808 0808 0808 0808 0808 0808     ................
230067d0:	0808 0808 0808 0808 0808 0808 0808 0808     ................
230067e0:	0001 0101                                   ....

Disassembly of section .itcm_region:

22014000 <src_buffer>:
	...

22015000 <uart_read>:
    if (dev->oflag & DEVICE_OFLAG_DMA_RX)
22015000:	01655783          	lhu	a5,22(a0)
{
22015004:	1101                	addi	sp,sp,-32
22015006:	ca26                	sw	s1,20(sp)
22015008:	c84a                	sw	s2,16(sp)
2201500a:	c64e                	sw	s3,12(sp)
2201500c:	ce06                	sw	ra,28(sp)
2201500e:	cc22                	sw	s0,24(sp)
    if (dev->oflag & DEVICE_OFLAG_DMA_RX)
22015010:	0207f793          	andi	a5,a5,32
{
22015014:	84aa                	mv	s1,a0
22015016:	8932                	mv	s2,a2
22015018:	89b6                	mv	s3,a3
    if (dev->oflag & DEVICE_OFLAG_DMA_RX)
2201501a:	c795                	beqz	a5,22015046 <uart_read+0x46>
        struct device *dma_ch = (struct device *)uart_device->rx_dma;
2201501c:	4160                	lw	s0,68(a0)
        if (!dma_ch)
2201501e:	c821                	beqz	s0,2201506e <uart_read+0x6e>
        if(uart_device->id == 0)
22015020:	03454783          	lbu	a5,52(a0)
22015024:	ef8d                	bnez	a5,2201505e <uart_read+0x5e>
            dma_reload(dma_ch, (uint32_t)DMA_ADDR_UART0_RDR, (uint32_t)buffer, size);
22015026:	4000a5b7          	lui	a1,0x4000a
2201502a:	08c58593          	addi	a1,a1,140 # 4000a08c <__ram_load_addr+0x1cffd168>
            dma_reload(dma_ch,(uint32_t)DMA_ADDR_UART1_RDR, (uint32_t)buffer, size);
2201502e:	8522                	mv	a0,s0
22015030:	00fec097          	auipc	ra,0xfec
22015034:	51c080e7          	jalr	1308(ra) # 2300154c <dma_reload>
            dma_channel_start(dma_ch);
22015038:	4601                	li	a2,0
2201503a:	45c5                	li	a1,17
2201503c:	8522                	mv	a0,s0
2201503e:	00ff0097          	auipc	ra,0xff0
22015042:	b7a080e7          	jalr	-1158(ra) # 23004bb8 <device_control>
}
22015046:	4462                	lw	s0,24(sp)
    return UART_ReceiveData(uart_device->id, (uint8_t *)buffer, size);
22015048:	0344c503          	lbu	a0,52(s1)
}
2201504c:	40f2                	lw	ra,28(sp)
2201504e:	44d2                	lw	s1,20(sp)
    return UART_ReceiveData(uart_device->id, (uint8_t *)buffer, size);
22015050:	864e                	mv	a2,s3
22015052:	85ca                	mv	a1,s2
}
22015054:	49b2                	lw	s3,12(sp)
22015056:	4942                	lw	s2,16(sp)
22015058:	6105                	addi	sp,sp,32
    return UART_ReceiveData(uart_device->id, (uint8_t *)buffer, size);
2201505a:	4330006f          	j	22015c8c <UART_ReceiveData>
        else if(uart_device->id == 1)
2201505e:	4705                	li	a4,1
22015060:	fee793e3          	bne	a5,a4,22015046 <uart_read+0x46>
            dma_reload(dma_ch,(uint32_t)DMA_ADDR_UART1_RDR, (uint32_t)buffer, size);
22015064:	4000a5b7          	lui	a1,0x4000a
22015068:	18c58593          	addi	a1,a1,396 # 4000a18c <__ram_load_addr+0x1cffd268>
2201506c:	b7c9                	j	2201502e <uart_read+0x2e>
}
2201506e:	40f2                	lw	ra,28(sp)
22015070:	4462                	lw	s0,24(sp)
22015072:	44d2                	lw	s1,20(sp)
22015074:	4942                	lw	s2,16(sp)
22015076:	49b2                	lw	s3,12(sp)
22015078:	557d                	li	a0,-1
2201507a:	6105                	addi	sp,sp,32
2201507c:	8082                	ret

2201507e <uart_isr>:
{
2201507e:	7135                	addi	sp,sp,-160
22015080:	cb26                	sw	s1,148(sp)
22015082:	c94a                	sw	s2,144(sp)
22015084:	cf06                	sw	ra,156(sp)
22015086:	cd22                	sw	s0,152(sp)
22015088:	c74e                	sw	s3,140(sp)
    uint32_t UARTx = (UART0_BASE + handle->id * 0x100);
2201508a:	03454983          	lbu	s3,52(a0)
    tmpVal = BL_RD_REG(UARTx, UART_INT_STS);
2201508e:	4000a7b7          	lui	a5,0x4000a
22015092:	02078713          	addi	a4,a5,32 # 4000a020 <__ram_load_addr+0x1cffd0fc>
    uint32_t UARTx = (UART0_BASE + handle->id * 0x100);
22015096:	09a2                	slli	s3,s3,0x8
    tmpVal = BL_RD_REG(UARTx, UART_INT_STS);
22015098:	974e                	add	a4,a4,s3
2201509a:	00072903          	lw	s2,0(a4)
    maskVal = BL_RD_REG(UARTx, UART_INT_MASK);
2201509e:	02478713          	addi	a4,a5,36
220150a2:	974e                	add	a4,a4,s3
220150a4:	4304                	lw	s1,0(a4)
    if (!handle->parent.callback)
220150a6:	5558                	lw	a4,44(a0)
220150a8:	12070763          	beqz	a4,220151d6 <uart_isr+0x158>
    if (BL_IS_REG_BIT_SET(tmpVal, UART_UTX_END_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_UTX_END_MASK))
220150ac:	00197693          	andi	a3,s2,1
220150b0:	842a                	mv	s0,a0
220150b2:	ce89                	beqz	a3,220150cc <uart_isr+0x4e>
220150b4:	0014f693          	andi	a3,s1,1
220150b8:	ea91                	bnez	a3,220150cc <uart_isr+0x4e>
        BL_WR_REG(UARTx, UART_INT_CLEAR, 0x1);
220150ba:	4685                	li	a3,1
220150bc:	02878793          	addi	a5,a5,40
220150c0:	97ce                	add	a5,a5,s3
220150c2:	c394                	sw	a3,0(a5)
        handle->parent.callback(&handle->parent, NULL, 0, UART_EVENT_TX_END);
220150c4:	4601                	li	a2,0
220150c6:	4681                	li	a3,0
220150c8:	4581                	li	a1,0
220150ca:	9702                	jalr	a4
    if (BL_IS_REG_BIT_SET(tmpVal, UART_URX_END_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_URX_END_MASK))
220150cc:	00297793          	andi	a5,s2,2
220150d0:	c38d                	beqz	a5,220150f2 <uart_isr+0x74>
220150d2:	0024f793          	andi	a5,s1,2
220150d6:	ef91                	bnez	a5,220150f2 <uart_isr+0x74>
        BL_WR_REG(UARTx, UART_INT_CLEAR, 0x2);
220150d8:	4000a7b7          	lui	a5,0x4000a
220150dc:	02878793          	addi	a5,a5,40 # 4000a028 <__ram_load_addr+0x1cffd104>
220150e0:	97ce                	add	a5,a5,s3
220150e2:	4709                	li	a4,2
220150e4:	c398                	sw	a4,0(a5)
        handle->parent.callback(&handle->parent,NULL, 0, UART_EVENT_RX_END);
220150e6:	545c                	lw	a5,44(s0)
220150e8:	4689                	li	a3,2
220150ea:	4601                	li	a2,0
220150ec:	4581                	li	a1,0
220150ee:	8522                	mv	a0,s0
220150f0:	9782                	jalr	a5
    if (BL_IS_REG_BIT_SET(tmpVal, UART_UTX_FIFO_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_UTX_FIFO_MASK))
220150f2:	00497793          	andi	a5,s2,4
220150f6:	cb91                	beqz	a5,2201510a <uart_isr+0x8c>
220150f8:	0044f793          	andi	a5,s1,4
220150fc:	e799                	bnez	a5,2201510a <uart_isr+0x8c>
        handle->parent.callback(&handle->parent, NULL, 0, UART_EVENT_TX_FIFO);
220150fe:	545c                	lw	a5,44(s0)
22015100:	4685                	li	a3,1
22015102:	4601                	li	a2,0
22015104:	4581                	li	a1,0
22015106:	8522                	mv	a0,s0
22015108:	9782                	jalr	a5
    if (BL_IS_REG_BIT_SET(tmpVal, UART_URX_FIFO_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_URX_FIFO_MASK))
2201510a:	00897793          	andi	a5,s2,8
2201510e:	c78d                	beqz	a5,22015138 <uart_isr+0xba>
22015110:	0084f793          	andi	a5,s1,8
22015114:	e395                	bnez	a5,22015138 <uart_isr+0xba>
        uint8_t len = UART_ReceiveData(handle->id, buffer, handle->fifo_threshold);
22015116:	03f44603          	lbu	a2,63(s0)
2201511a:	03444503          	lbu	a0,52(s0)
2201511e:	858a                	mv	a1,sp
22015120:	36d000ef          	jal	ra,22015c8c <UART_ReceiveData>
        if(len)
22015124:	0ff57793          	andi	a5,a0,255
22015128:	cb81                	beqz	a5,22015138 <uart_isr+0xba>
            handle->parent.callback(&handle->parent, &buffer[0], len, UART_EVENT_RX_FIFO);
2201512a:	545c                	lw	a5,44(s0)
2201512c:	0ff57613          	andi	a2,a0,255
22015130:	468d                	li	a3,3
22015132:	858a                	mv	a1,sp
22015134:	8522                	mv	a0,s0
22015136:	9782                	jalr	a5
    if (BL_IS_REG_BIT_SET(tmpVal, UART_URX_RTO_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_URX_RTO_MASK))
22015138:	01097793          	andi	a5,s2,16
2201513c:	cf85                	beqz	a5,22015174 <uart_isr+0xf6>
2201513e:	0104f793          	andi	a5,s1,16
22015142:	eb8d                	bnez	a5,22015174 <uart_isr+0xf6>
        uint8_t len = UART_ReceiveData(handle->id, buffer, UART_FIFO_MAX_LEN);
22015144:	03444503          	lbu	a0,52(s0)
22015148:	08000613          	li	a2,128
2201514c:	858a                	mv	a1,sp
2201514e:	33f000ef          	jal	ra,22015c8c <UART_ReceiveData>
        if(len)
22015152:	0ff57793          	andi	a5,a0,255
22015156:	cb81                	beqz	a5,22015166 <uart_isr+0xe8>
            handle->parent.callback(&handle->parent, &buffer[0], len, UART_EVENT_RTO);
22015158:	545c                	lw	a5,44(s0)
2201515a:	0ff57613          	andi	a2,a0,255
2201515e:	4691                	li	a3,4
22015160:	858a                	mv	a1,sp
22015162:	8522                	mv	a0,s0
22015164:	9782                	jalr	a5
        BL_WR_REG(UARTx, UART_INT_CLEAR, 0x10);
22015166:	4000a7b7          	lui	a5,0x4000a
2201516a:	02878793          	addi	a5,a5,40 # 4000a028 <__ram_load_addr+0x1cffd104>
2201516e:	97ce                	add	a5,a5,s3
22015170:	4741                	li	a4,16
22015172:	c398                	sw	a4,0(a5)
    if (BL_IS_REG_BIT_SET(tmpVal, UART_URX_PCE_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_URX_PCE_MASK))
22015174:	02097793          	andi	a5,s2,32
22015178:	c785                	beqz	a5,220151a0 <uart_isr+0x122>
2201517a:	0204f793          	andi	a5,s1,32
2201517e:	e38d                	bnez	a5,220151a0 <uart_isr+0x122>
        BL_WR_REG(UARTx, UART_INT_CLEAR, 0x20);
22015180:	4000a7b7          	lui	a5,0x4000a
22015184:	02878793          	addi	a5,a5,40 # 4000a028 <__ram_load_addr+0x1cffd104>
22015188:	99be                	add	s3,s3,a5
2201518a:	02000793          	li	a5,32
2201518e:	00f9a023          	sw	a5,0(s3)
        handle->parent.callback(&handle->parent, NULL, 0, UART_PCE_IT);
22015192:	545c                	lw	a5,44(s0)
22015194:	02000693          	li	a3,32
22015198:	4601                	li	a2,0
2201519a:	4581                	li	a1,0
2201519c:	8522                	mv	a0,s0
2201519e:	9782                	jalr	a5
    if (BL_IS_REG_BIT_SET(tmpVal, UART_UTX_FER_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_UTX_FER_MASK))
220151a0:	04097793          	andi	a5,s2,64
220151a4:	cb99                	beqz	a5,220151ba <uart_isr+0x13c>
220151a6:	0404f793          	andi	a5,s1,64
220151aa:	eb81                	bnez	a5,220151ba <uart_isr+0x13c>
        handle->parent.callback(&handle->parent, NULL, 0, UART_TX_FER_IT);
220151ac:	545c                	lw	a5,44(s0)
220151ae:	04000693          	li	a3,64
220151b2:	4601                	li	a2,0
220151b4:	4581                	li	a1,0
220151b6:	8522                	mv	a0,s0
220151b8:	9782                	jalr	a5
    if (BL_IS_REG_BIT_SET(tmpVal, UART_URX_FER_INT) && !BL_IS_REG_BIT_SET(maskVal, UART_CR_URX_FER_MASK))
220151ba:	08097913          	andi	s2,s2,128
220151be:	00090c63          	beqz	s2,220151d6 <uart_isr+0x158>
220151c2:	0804f493          	andi	s1,s1,128
220151c6:	e881                	bnez	s1,220151d6 <uart_isr+0x158>
        handle->parent.callback(&handle->parent, NULL, 0, UART_RX_FER_IT);
220151c8:	545c                	lw	a5,44(s0)
220151ca:	08000693          	li	a3,128
220151ce:	4601                	li	a2,0
220151d0:	4581                	li	a1,0
220151d2:	8522                	mv	a0,s0
220151d4:	9782                	jalr	a5
}
220151d6:	40fa                	lw	ra,156(sp)
220151d8:	446a                	lw	s0,152(sp)
220151da:	44da                	lw	s1,148(sp)
220151dc:	494a                	lw	s2,144(sp)
220151de:	49ba                	lw	s3,140(sp)
220151e0:	610d                	addi	sp,sp,160
220151e2:	8082                	ret

220151e4 <UART0_IRQ>:
    uart_isr(&uartx_device[UART0_INDEX]);
220151e4:	42024537          	lui	a0,0x42024
220151e8:	1cc50513          	addi	a0,a0,460 # 420241cc <uartx_device>
220151ec:	bd49                	j	2201507e <uart_isr>
    tmpVal=BL_RD_REG(HBN_BASE,HBN_GLB);
220151ee:	4000f737          	lui	a4,0x4000f
220151f2:	5b1c                	lw	a5,48(a4)
{
220151f4:	1141                	addi	sp,sp,-16
220151f6:	c606                	sw	ra,12(sp)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_ROOT_CLK_SEL,0);
220151f8:	9bf1                	andi	a5,a5,-4
    BL_WR_REG(HBN_BASE,HBN_GLB,tmpVal);
220151fa:	db1c                	sw	a5,48(a4)
    GLB_CLK_SET_DUMMY_WAIT;
220151fc:	0001                	nop
220151fe:	0001                	nop
22015200:	0001                	nop
22015202:	0001                	nop
22015204:	0001                	nop
22015206:	0001                	nop
22015208:	0001                	nop
2201520a:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG0);
2201520c:	400007b7          	lui	a5,0x40000
22015210:	4398                	lw	a4,0(a5)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_HCLK_DIV,0);
22015212:	ff0006b7          	lui	a3,0xff000
22015216:	0ff68693          	addi	a3,a3,255 # ff0000ff <__HeapLimit+0xbcfd40ff>
2201521a:	8f75                	and	a4,a4,a3
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG0,tmpVal);
2201521c:	c398                	sw	a4,0(a5)
    GLB_REG_BCLK_DIS_TRUE;
2201521e:	4685                	li	a3,1
22015220:	40001737          	lui	a4,0x40001
22015224:	fed72e23          	sw	a3,-4(a4) # 40000ffc <__ram_load_addr+0x1cff40d8>
    GLB_REG_BCLK_DIS_FALSE;
22015228:	fe072e23          	sw	zero,-4(a4)
    GLB_CLK_SET_DUMMY_WAIT;
2201522c:	0001                	nop
2201522e:	0001                	nop
22015230:	0001                	nop
22015232:	0001                	nop
22015234:	0001                	nop
22015236:	0001                	nop
22015238:	0001                	nop
2201523a:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
2201523c:	4f98                	lw	a4,24(a5)
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_CTRL_PWRON_RST);
2201523e:	9b61                	andi	a4,a4,-8
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
22015240:	cf98                	sw	a4,24(a5)
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
22015242:	4f98                	lw	a4,24(a5)
    tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_CTRL_CPU_RESET);
22015244:	00676713          	ori	a4,a4,6
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
22015248:	cf98                	sw	a4,24(a5)
        BL702_Delay_US(10);
2201524a:	4529                	li	a0,10
2201524c:	2b05                	jal	2201577c <BL702_Delay_US>
    while(1){
2201524e:	bff5                	j	2201524a <UART0_IRQ+0x66>
    tmpVal=BL_RD_REG(HBN_BASE,HBN_GLB);
22015250:	4000f737          	lui	a4,0x4000f
22015254:	5b1c                	lw	a5,48(a4)
{
22015256:	1141                	addi	sp,sp,-16
22015258:	c606                	sw	ra,12(sp)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_ROOT_CLK_SEL,0);
2201525a:	9bf1                	andi	a5,a5,-4
    BL_WR_REG(HBN_BASE,HBN_GLB,tmpVal);
2201525c:	db1c                	sw	a5,48(a4)
    GLB_CLK_SET_DUMMY_WAIT;
2201525e:	0001                	nop
22015260:	0001                	nop
22015262:	0001                	nop
22015264:	0001                	nop
22015266:	0001                	nop
22015268:	0001                	nop
2201526a:	0001                	nop
2201526c:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG0);
2201526e:	400007b7          	lui	a5,0x40000
22015272:	4398                	lw	a4,0(a5)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_HCLK_DIV,0);
22015274:	ff0006b7          	lui	a3,0xff000
22015278:	0ff68693          	addi	a3,a3,255 # ff0000ff <__HeapLimit+0xbcfd40ff>
2201527c:	8f75                	and	a4,a4,a3
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG0,tmpVal);
2201527e:	c398                	sw	a4,0(a5)
    GLB_REG_BCLK_DIS_TRUE;
22015280:	4685                	li	a3,1
22015282:	40001737          	lui	a4,0x40001
22015286:	fed72e23          	sw	a3,-4(a4) # 40000ffc <__ram_load_addr+0x1cff40d8>
    GLB_REG_BCLK_DIS_FALSE;
2201528a:	fe072e23          	sw	zero,-4(a4)
    GLB_CLK_SET_DUMMY_WAIT;
2201528e:	0001                	nop
22015290:	0001                	nop
22015292:	0001                	nop
22015294:	0001                	nop
22015296:	0001                	nop
22015298:	0001                	nop
2201529a:	0001                	nop
2201529c:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
2201529e:	4f98                	lw	a4,24(a5)
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_CTRL_PWRON_RST);
220152a0:	9b61                	andi	a4,a4,-8
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
220152a2:	cf98                	sw	a4,24(a5)
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
220152a4:	4f98                	lw	a4,24(a5)
    tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_CTRL_CPU_RESET);
220152a6:	00276713          	ori	a4,a4,2
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
220152aa:	cf98                	sw	a4,24(a5)
        BL702_Delay_US(10);
220152ac:	4529                	li	a0,10
220152ae:	21f9                	jal	2201577c <BL702_Delay_US>
    while(1){
220152b0:	bff5                	j	220152ac <UART0_IRQ+0xc8>
    tmpVal=BL_RD_REG(HBN_BASE,HBN_GLB);
220152b2:	4000f737          	lui	a4,0x4000f
220152b6:	5b1c                	lw	a5,48(a4)
{
220152b8:	1141                	addi	sp,sp,-16
220152ba:	c606                	sw	ra,12(sp)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_ROOT_CLK_SEL,0);
220152bc:	9bf1                	andi	a5,a5,-4
    BL_WR_REG(HBN_BASE,HBN_GLB,tmpVal);
220152be:	db1c                	sw	a5,48(a4)
    GLB_CLK_SET_DUMMY_WAIT;
220152c0:	0001                	nop
220152c2:	0001                	nop
220152c4:	0001                	nop
220152c6:	0001                	nop
220152c8:	0001                	nop
220152ca:	0001                	nop
220152cc:	0001                	nop
220152ce:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_CLK_CFG0);
220152d0:	400007b7          	lui	a5,0x40000
220152d4:	4398                	lw	a4,0(a5)
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_HCLK_DIV,0);
220152d6:	ff0006b7          	lui	a3,0xff000
220152da:	0ff68693          	addi	a3,a3,255 # ff0000ff <__HeapLimit+0xbcfd40ff>
220152de:	8f75                	and	a4,a4,a3
    BL_WR_REG(GLB_BASE,GLB_CLK_CFG0,tmpVal);
220152e0:	c398                	sw	a4,0(a5)
    GLB_REG_BCLK_DIS_TRUE;
220152e2:	4685                	li	a3,1
220152e4:	40001737          	lui	a4,0x40001
220152e8:	fed72e23          	sw	a3,-4(a4) # 40000ffc <__ram_load_addr+0x1cff40d8>
    GLB_REG_BCLK_DIS_FALSE;
220152ec:	fe072e23          	sw	zero,-4(a4)
    GLB_CLK_SET_DUMMY_WAIT;
220152f0:	0001                	nop
220152f2:	0001                	nop
220152f4:	0001                	nop
220152f6:	0001                	nop
220152f8:	0001                	nop
220152fa:	0001                	nop
220152fc:	0001                	nop
220152fe:	0001                	nop
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
22015300:	4f98                	lw	a4,24(a5)
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_CTRL_PWRON_RST);
22015302:	9b61                	andi	a4,a4,-8
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
22015304:	cf98                	sw	a4,24(a5)
    tmpVal=BL_RD_REG(GLB_BASE,GLB_SWRST_CFG2);
22015306:	4f98                	lw	a4,24(a5)
    tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_CTRL_PWRON_RST);
22015308:	00776713          	ori	a4,a4,7
    BL_WR_REG(GLB_BASE,GLB_SWRST_CFG2,tmpVal);
2201530c:	cf98                	sw	a4,24(a5)
        BL702_Delay_US(10);
2201530e:	4529                	li	a0,10
22015310:	21b5                	jal	2201577c <BL702_Delay_US>
    while(1){
22015312:	bff5                	j	2201530e <UART0_IRQ+0x12a>
    tmpVal=BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO);
22015314:	40000737          	lui	a4,0x40000
22015318:	08872783          	lw	a5,136(a4) # 40000088 <__ram_load_addr+0x1cff3164>
}
2201531c:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_CFG_GPIO_USE_PSRAM_IO,0x3f);
2201531e:	03f7e793          	ori	a5,a5,63
    BL_WR_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO,tmpVal);
22015322:	08f72423          	sw	a5,136(a4)
}
22015326:	8082                	ret
    tmpVal=BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO);
22015328:	40000737          	lui	a4,0x40000
2201532c:	08872783          	lw	a5,136(a4) # 40000088 <__ram_load_addr+0x1cff3164>
}
22015330:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_CFG_GPIO_USE_PSRAM_IO,0x00);
22015332:	fc07f793          	andi	a5,a5,-64
    BL_WR_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO,tmpVal);
22015336:	08f72423          	sw	a5,136(a4)
}
2201533a:	8082                	ret
    tmpVal=BL_RD_REG(GLB_BASE,GLB_PARM);
2201533c:	40000737          	lui	a4,0x40000
22015340:	08072783          	lw	a5,128(a4) # 40000080 <__ram_load_addr+0x1cff315c>
}
22015344:	4501                	li	a0,0
    tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_CFG_SFLASH2_SWAP_IO0_IO3);
22015346:	cff7f793          	andi	a5,a5,-769
    BL_WR_REG(GLB_BASE,GLB_PARM,tmpVal);
2201534a:	08f72023          	sw	a5,128(a4)
}
2201534e:	8082                	ret
    tmpVal=BL_RD_REG(GLB_BASE,GLB_PARM);
22015350:	40000737          	lui	a4,0x40000
22015354:	08072783          	lw	a5,128(a4) # 40000080 <__ram_load_addr+0x1cff315c>
}
22015358:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BIT(tmpVal,GLB_CFG_SFLASH2_SWAP_CS_IO2);
2201535a:	2007e793          	ori	a5,a5,512
    BL_WR_REG(GLB_BASE,GLB_PARM,tmpVal);
2201535e:	08f72023          	sw	a5,128(a4)
}
22015362:	8082                	ret
    tmpVal=BL_RD_REG(GLB_BASE,GLB_PARM);
22015364:	40000737          	lui	a4,0x40000
22015368:	08072783          	lw	a5,128(a4) # 40000080 <__ram_load_addr+0x1cff315c>
}
2201536c:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BIT(tmpVal,GLB_CFG_SFLASH2_SWAP_IO0_IO3);
2201536e:	1007e793          	ori	a5,a5,256
    BL_WR_REG(GLB_BASE,GLB_PARM,tmpVal);
22015372:	08f72023          	sw	a5,128(a4)
}
22015376:	8082                	ret
}
22015378:	4501                	li	a0,0
2201537a:	8082                	ret
    tmpVal=BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO);
2201537c:	40000737          	lui	a4,0x40000
22015380:	08872783          	lw	a5,136(a4) # 40000088 <__ram_load_addr+0x1cff3164>
}
22015384:	4501                	li	a0,0
    tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_CFG_GPIO_USE_PSRAM_IO,0x00);
22015386:	fc07f793          	andi	a5,a5,-64
    BL_WR_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO,tmpVal);
2201538a:	08f72423          	sw	a5,136(a4)
}
2201538e:	8082                	ret

22015390 <GLB_GPIO_Init>:
    uint8_t gpioPin=cfg->gpioPin;
22015390:	00054803          	lbu	a6,0(a0)
    pOut=(uint32_t *)(GLB_BASE+GLB_GPIO_OUTPUT_EN_OFFSET+((gpioPin>>5)<<2));
22015394:	400007b7          	lui	a5,0x40000
22015398:	19078713          	addi	a4,a5,400 # 40000190 <__ram_load_addr+0x1cff326c>
2201539c:	00585313          	srli	t1,a6,0x5
220153a0:	030a                	slli	t1,t1,0x2
220153a2:	933a                	add	t1,t1,a4
    tmpOut=*pOut;
220153a4:	00032703          	lw	a4,0(t1)
    tmpOut &= (~(1<<pos));
220153a8:	4f85                	li	t6,1
220153aa:	010f9f33          	sll	t5,t6,a6
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220153ae:	00185e13          	srli	t3,a6,0x1
220153b2:	10078793          	addi	a5,a5,256
    tmpOut &= (~(1<<pos));
220153b6:	ffff4893          	not	a7,t5
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220153ba:	0e0a                	slli	t3,t3,0x2
    tmpOut &= (~(1<<pos));
220153bc:	00e8f8b3          	and	a7,a7,a4
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220153c0:	9e3e                	add	t3,t3,a5
    *pOut=tmpOut;
220153c2:	01132023          	sw	a7,0(t1)
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220153c6:	000e2783          	lw	a5,0(t3)
    if(gpioPin%2==0){
220153ca:	00187693          	andi	a3,a6,1
220153ce:	00254583          	lbu	a1,2(a0)
220153d2:	00454603          	lbu	a2,4(a0)
220153d6:	00554703          	lbu	a4,5(a0)
220153da:	00154e83          	lbu	t4,1(a0)
220153de:	e2d5                	bnez	a3,22015482 <GLB_GPIO_Init+0xf2>
        if(cfg->gpioMode!=GPIO_MODE_ANALOG){
220153e0:	428d                	li	t0,3
            tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_0_PD);
220153e2:	fce7f693          	andi	a3,a5,-50
        if(cfg->gpioMode!=GPIO_MODE_ANALOG){
220153e6:	02558163          	beq	a1,t0,22015408 <GLB_GPIO_Init+0x78>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_0_IE);
220153ea:	0017e693          	ori	a3,a5,1
            if(cfg->gpioMode==GPIO_MODE_OUTPUT){
220153ee:	01f59663          	bne	a1,t6,220153fa <GLB_GPIO_Init+0x6a>
                tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_0_IE);
220153f2:	ffe7f693          	andi	a3,a5,-2
                tmpOut |= (1<<pos);
220153f6:	01e8e8b3          	or	a7,a7,t5
            if(cfg->pullType==GPIO_PULL_UP){
220153fa:	00354783          	lbu	a5,3(a0)
            tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_0_PD);
220153fe:	fcf6f693          	andi	a3,a3,-49
            if(cfg->pullType==GPIO_PULL_UP){
22015402:	ebb5                	bnez	a5,22015476 <GLB_GPIO_Init+0xe6>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_0_PU);
22015404:	0106e693          	ori	a3,a3,16
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_0_DRV,cfg->drive);
22015408:	060a                	slli	a2,a2,0x2
2201540a:	9ac5                	andi	a3,a3,-15
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_0_SMT,cfg->smtCtrl);
2201540c:	8ed1                	or	a3,a3,a2
2201540e:	0706                	slli	a4,a4,0x1
22015410:	8f55                	or	a4,a4,a3
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_0_FUNC_SEL,cfg->gpioFun);
22015412:	76f9                	lui	a3,0xffffe
22015414:	0ff68693          	addi	a3,a3,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
22015418:	8f75                	and	a4,a4,a3
2201541a:	008e9693          	slli	a3,t4,0x8
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL,cfg->gpioFun);
2201541e:	8ed9                	or	a3,a3,a4
    BL_WR_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4,tmpVal);
22015420:	00de2023          	sw	a3,0(t3)
    if(gpioPin>=9&&gpioPin<=13){
22015424:	ff780793          	addi	a5,a6,-9
    *pOut=tmpOut;
22015428:	01132023          	sw	a7,0(t1)
    if(gpioPin>=9&&gpioPin<=13){
2201542c:	4711                	li	a4,4
2201542e:	0ff7f893          	andi	a7,a5,255
22015432:	0b176c63          	bltu	a4,a7,220154ea <GLB_GPIO_Init+0x15a>
        tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
22015436:	4000f737          	lui	a4,0x4000f
2201543a:	4b50                	lw	a2,20(a4)
        aonPadIeSmt=BL_GET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT);
2201543c:	4505                	li	a0,1
        if(cfg->gpioMode!=GPIO_MODE_ANALOG){
2201543e:	470d                	li	a4,3
        aonPadIeSmt=BL_GET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT);
22015440:	00865693          	srli	a3,a2,0x8
22015444:	8afd                	andi	a3,a3,31
        if(cfg->gpioMode!=GPIO_MODE_ANALOG){
22015446:	00f517b3          	sll	a5,a0,a5
2201544a:	00e58663          	beq	a1,a4,22015456 <GLB_GPIO_Init+0xc6>
                aonPadIeSmt|=(1<<(gpioPin-9));
2201544e:	00d7e733          	or	a4,a5,a3
            if(cfg->gpioMode==GPIO_MODE_OUTPUT){
22015452:	00a59663          	bne	a1,a0,2201545e <GLB_GPIO_Init+0xce>
            aonPadIeSmt&=~(1<<(gpioPin-9));
22015456:	fff7c793          	not	a5,a5
2201545a:	00d7f733          	and	a4,a5,a3
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
2201545e:	77f9                	lui	a5,0xffffe
22015460:	0ff78793          	addi	a5,a5,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
22015464:	8e7d                	and	a2,a2,a5
22015466:	00871793          	slli	a5,a4,0x8
2201546a:	8fd1                	or	a5,a5,a2
        BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
2201546c:	4000f737          	lui	a4,0x4000f
22015470:	cb5c                	sw	a5,20(a4)
}
22015472:	4501                	li	a0,0
22015474:	8082                	ret
            }else if(cfg->pullType==GPIO_PULL_DOWN){
22015476:	4f05                	li	t5,1
22015478:	f9e798e3          	bne	a5,t5,22015408 <GLB_GPIO_Init+0x78>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_0_PD);
2201547c:	0206e693          	ori	a3,a3,32
22015480:	b761                	j	22015408 <GLB_GPIO_Init+0x78>
        if(cfg->gpioMode!=GPIO_MODE_ANALOG){
22015482:	468d                	li	a3,3
22015484:	04d58e63          	beq	a1,a3,220154e0 <GLB_GPIO_Init+0x150>
            if(cfg->gpioMode==GPIO_MODE_OUTPUT) {
22015488:	05f59363          	bne	a1,t6,220154ce <GLB_GPIO_Init+0x13e>
                tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_1_IE);
2201548c:	76c1                	lui	a3,0xffff0
2201548e:	16fd                	addi	a3,a3,-1
22015490:	8ff5                	and	a5,a5,a3
                tmpOut |= (1<<pos);
22015492:	01e8e8b3          	or	a7,a7,t5
            tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_1_PD);
22015496:	ffd006b7          	lui	a3,0xffd00
2201549a:	16fd                	addi	a3,a3,-1
2201549c:	8ff5                	and	a5,a5,a3
            if(cfg->pullType==GPIO_PULL_UP){
2201549e:	00354683          	lbu	a3,3(a0)
220154a2:	ea8d                	bnez	a3,220154d4 <GLB_GPIO_Init+0x144>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_1_PU);
220154a4:	001006b7          	lui	a3,0x100
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_1_PD);
220154a8:	8fd5                	or	a5,a5,a3
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_DRV,cfg->drive);
220154aa:	fff406b7          	lui	a3,0xfff40
220154ae:	16fd                	addi	a3,a3,-1
220154b0:	064a                	slli	a2,a2,0x12
220154b2:	8ff5                	and	a5,a5,a3
220154b4:	8fd1                	or	a5,a5,a2
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_SMT,cfg->smtCtrl);
220154b6:	7601                	lui	a2,0xfffe0
220154b8:	167d                	addi	a2,a2,-1
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL,cfg->gpioFun);
220154ba:	e10006b7          	lui	a3,0xe1000
220154be:	16fd                	addi	a3,a3,-1
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_SMT,cfg->smtCtrl);
220154c0:	8e7d                	and	a2,a2,a5
220154c2:	0746                	slli	a4,a4,0x11
220154c4:	8f51                	or	a4,a4,a2
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL,cfg->gpioFun);
220154c6:	8f75                	and	a4,a4,a3
220154c8:	018e9693          	slli	a3,t4,0x18
220154cc:	bf89                	j	2201541e <GLB_GPIO_Init+0x8e>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_1_IE);
220154ce:	66c1                	lui	a3,0x10
220154d0:	8fd5                	or	a5,a5,a3
220154d2:	b7d1                	j	22015496 <GLB_GPIO_Init+0x106>
            }else if(cfg->pullType==GPIO_PULL_DOWN){
220154d4:	4f05                	li	t5,1
220154d6:	fde69ae3          	bne	a3,t5,220154aa <GLB_GPIO_Init+0x11a>
                tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_1_PD);
220154da:	002006b7          	lui	a3,0x200
220154de:	b7e9                	j	220154a8 <GLB_GPIO_Init+0x118>
            tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_1_PD);
220154e0:	ffcf06b7          	lui	a3,0xffcf0
220154e4:	16fd                	addi	a3,a3,-1
220154e6:	8ff5                	and	a5,a5,a3
220154e8:	b7c9                	j	220154aa <GLB_GPIO_Init+0x11a>
    if(gpioPin>=32&&gpioPin<=37){
220154ea:	fe080793          	addi	a5,a6,-32
220154ee:	0ff7f693          	andi	a3,a5,255
220154f2:	4715                	li	a4,5
220154f4:	f6d76fe3          	bltu	a4,a3,22015472 <GLB_GPIO_Init+0xe2>
        if(BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO)&(1<<(gpioPin-32))){
220154f8:	40000637          	lui	a2,0x40000
220154fc:	08862683          	lw	a3,136(a2) # 40000088 <__ram_load_addr+0x1cff3164>
22015500:	4705                	li	a4,1
22015502:	00f71733          	sll	a4,a4,a5
22015506:	8f75                	and	a4,a4,a3
22015508:	d72d                	beqz	a4,22015472 <GLB_GPIO_Init+0xe2>
            tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
2201550a:	0018d693          	srli	a3,a7,0x1
2201550e:	10060613          	addi	a2,a2,256
22015512:	068a                	slli	a3,a3,0x2
22015514:	96b2                	add	a3,a3,a2
22015516:	4290                	lw	a2,0(a3)
            if(gpioPin%2==0){
22015518:	0018f793          	andi	a5,a7,1
2201551c:	00154703          	lbu	a4,1(a0)
22015520:	ef8d                	bnez	a5,2201555a <GLB_GPIO_Init+0x1ca>
                tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_0_FUNC_SEL,cfg->gpioFun);
22015522:	77f9                	lui	a5,0xffffe
22015524:	0ff78793          	addi	a5,a5,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
22015528:	8e7d                	and	a2,a2,a5
2201552a:	00871793          	slli	a5,a4,0x8
                tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL,cfg->gpioFun);
2201552e:	8fd1                	or	a5,a5,a2
            BL_WR_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4,tmpVal);
22015530:	c29c                	sw	a5,0(a3)
            pOut=(uint32_t *)(GLB_BASE+GLB_GPIO_OUTPUT_EN_OFFSET+((gpioPin>>5)<<2));
22015532:	0058d713          	srli	a4,a7,0x5
22015536:	400007b7          	lui	a5,0x40000
2201553a:	19078793          	addi	a5,a5,400 # 40000190 <__ram_load_addr+0x1cff326c>
2201553e:	070a                	slli	a4,a4,0x2
22015540:	973e                	add	a4,a4,a5
            tmpOut=*pOut;
22015542:	4308                	lw	a0,0(a4)
            tmpOut &= (~(1<<pos));
22015544:	4605                	li	a2,1
22015546:	011617b3          	sll	a5,a2,a7
2201554a:	fff7c693          	not	a3,a5
2201554e:	8ee9                	and	a3,a3,a0
                if(cfg->gpioMode==GPIO_MODE_OUTPUT){
22015550:	00c59363          	bne	a1,a2,22015556 <GLB_GPIO_Init+0x1c6>
                    tmpOut |= (1<<pos);
22015554:	8edd                	or	a3,a3,a5
            *pOut=tmpOut;
22015556:	c314                	sw	a3,0(a4)
22015558:	bf29                	j	22015472 <GLB_GPIO_Init+0xe2>
                tmpVal=BL_SET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL,cfg->gpioFun);
2201555a:	e10007b7          	lui	a5,0xe1000
2201555e:	17fd                	addi	a5,a5,-1
22015560:	8e7d                	and	a2,a2,a5
22015562:	01871793          	slli	a5,a4,0x18
22015566:	b7e1                	j	2201552e <GLB_GPIO_Init+0x19e>

22015568 <GLB_GPIO_INPUT_Enable>:
    pinOffset=(gpioPin>>1)<<2;
22015568:	00155793          	srli	a5,a0,0x1
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
2201556c:	40000737          	lui	a4,0x40000
22015570:	10070713          	addi	a4,a4,256 # 40000100 <__ram_load_addr+0x1cff31dc>
    pinOffset=(gpioPin>>1)<<2;
22015574:	078a                	slli	a5,a5,0x2
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
22015576:	97ba                	add	a5,a5,a4
    if(gpioPin%2==0){
22015578:	00157693          	andi	a3,a0,1
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
2201557c:	4398                	lw	a4,0(a5)
    if(gpioPin%2==0){
2201557e:	ee95                	bnez	a3,220155ba <GLB_GPIO_INPUT_Enable+0x52>
        tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_0_IE);
22015580:	00176713          	ori	a4,a4,1
    *(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset)=tmpVal;
22015584:	c398                	sw	a4,0(a5)
    if(gpioPin>=9&&gpioPin<=13){
22015586:	155d                	addi	a0,a0,-9
22015588:	0ff57713          	andi	a4,a0,255
2201558c:	4791                	li	a5,4
2201558e:	02e7e463          	bltu	a5,a4,220155b6 <GLB_GPIO_INPUT_Enable+0x4e>
        tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
22015592:	4000f637          	lui	a2,0x4000f
22015596:	4a58                	lw	a4,20(a2)
        aonPadIeSmt=BL_GET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT);
22015598:	00875793          	srli	a5,a4,0x8
2201559c:	01f7f693          	andi	a3,a5,31
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
220155a0:	77f9                	lui	a5,0xffffe
220155a2:	0ff78793          	addi	a5,a5,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
220155a6:	8f7d                	and	a4,a4,a5
        aonPadIeSmt|=(1<<(gpioPin-9));
220155a8:	4785                	li	a5,1
220155aa:	00a797b3          	sll	a5,a5,a0
220155ae:	8fd5                	or	a5,a5,a3
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
220155b0:	07a2                	slli	a5,a5,0x8
220155b2:	8fd9                	or	a5,a5,a4
        BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
220155b4:	ca5c                	sw	a5,20(a2)
}
220155b6:	4501                	li	a0,0
220155b8:	8082                	ret
        tmpVal=BL_SET_REG_BIT(tmpVal,GLB_REG_GPIO_1_IE);
220155ba:	66c1                	lui	a3,0x10
220155bc:	8f55                	or	a4,a4,a3
220155be:	b7d9                	j	22015584 <GLB_GPIO_INPUT_Enable+0x1c>

220155c0 <GLB_GPIO_INPUT_Disable>:
    pinOffset=(gpioPin>>1)<<2;
220155c0:	00155793          	srli	a5,a0,0x1
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
220155c4:	40000737          	lui	a4,0x40000
220155c8:	10070713          	addi	a4,a4,256 # 40000100 <__ram_load_addr+0x1cff31dc>
    pinOffset=(gpioPin>>1)<<2;
220155cc:	078a                	slli	a5,a5,0x2
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
220155ce:	97ba                	add	a5,a5,a4
    if(gpioPin%2==0){
220155d0:	00157693          	andi	a3,a0,1
    tmpVal=*(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset);
220155d4:	4398                	lw	a4,0(a5)
    if(gpioPin%2==0){
220155d6:	e2a1                	bnez	a3,22015616 <GLB_GPIO_INPUT_Disable+0x56>
        tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_0_IE);
220155d8:	9b79                	andi	a4,a4,-2
    *(uint32_t *)(GLB_BASE+GLB_GPIO_OFFSET+pinOffset)=tmpVal;
220155da:	c398                	sw	a4,0(a5)
    if(gpioPin>=9&&gpioPin<=13){
220155dc:	155d                	addi	a0,a0,-9
220155de:	0ff57713          	andi	a4,a0,255
220155e2:	4791                	li	a5,4
220155e4:	02e7e763          	bltu	a5,a4,22015612 <GLB_GPIO_INPUT_Disable+0x52>
        tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
220155e8:	4000f637          	lui	a2,0x4000f
220155ec:	4a54                	lw	a3,20(a2)
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
220155ee:	7779                	lui	a4,0xffffe
220155f0:	0ff70713          	addi	a4,a4,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
        aonPadIeSmt&=~(1<<(gpioPin-9));
220155f4:	4785                	li	a5,1
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
220155f6:	8f75                	and	a4,a4,a3
        aonPadIeSmt&=~(1<<(gpioPin-9));
220155f8:	00a797b3          	sll	a5,a5,a0
        aonPadIeSmt=BL_GET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT);
220155fc:	82a1                	srli	a3,a3,0x8
        aonPadIeSmt&=~(1<<(gpioPin-9));
220155fe:	fff7c793          	not	a5,a5
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
22015602:	8ff5                	and	a5,a5,a3
22015604:	6689                	lui	a3,0x2
22015606:	07a2                	slli	a5,a5,0x8
22015608:	f0068693          	addi	a3,a3,-256 # 1f00 <HeapSize+0xf00>
2201560c:	8ff5                	and	a5,a5,a3
2201560e:	8fd9                	or	a5,a5,a4
        BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
22015610:	ca5c                	sw	a5,20(a2)
}
22015612:	4501                	li	a0,0
22015614:	8082                	ret
        tmpVal=BL_CLR_REG_BIT(tmpVal,GLB_REG_GPIO_1_IE);
22015616:	76c1                	lui	a3,0xffff0
22015618:	16fd                	addi	a3,a3,-1
2201561a:	8f75                	and	a4,a4,a3
2201561c:	bf7d                	j	220155da <GLB_GPIO_INPUT_Disable+0x1a>

2201561e <GLB_GPIO_OUTPUT_Enable>:
    if(gpioPin>=32&&gpioPin<=37){
2201561e:	fe050713          	addi	a4,a0,-32
22015622:	0ff77693          	andi	a3,a4,255
22015626:	4795                	li	a5,5
22015628:	00d7ee63          	bltu	a5,a3,22015644 <GLB_GPIO_OUTPUT_Enable+0x26>
        if(BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO)&(1<<(gpioPin-32))){
2201562c:	400007b7          	lui	a5,0x40000
22015630:	0887a683          	lw	a3,136(a5) # 40000088 <__ram_load_addr+0x1cff3164>
22015634:	4785                	li	a5,1
22015636:	00e797b3          	sll	a5,a5,a4
2201563a:	8ff5                	and	a5,a5,a3
2201563c:	c781                	beqz	a5,22015644 <GLB_GPIO_OUTPUT_Enable+0x26>
            gpioPin-=9;
2201563e:	155d                	addi	a0,a0,-9
22015640:	0ff57513          	andi	a0,a0,255
    tmpVal=BL_RD_REG(GLB_BASE,GLB_GPIO_CFGCTL34);
22015644:	40000737          	lui	a4,0x40000
22015648:	19072683          	lw	a3,400(a4) # 40000190 <__ram_load_addr+0x1cff326c>
    tmpVal=tmpVal|(1<<gpioPin);
2201564c:	4785                	li	a5,1
2201564e:	00a79533          	sll	a0,a5,a0
22015652:	8d55                	or	a0,a0,a3
    BL_WR_REG(GLB_BASE,GLB_GPIO_CFGCTL34,tmpVal);
22015654:	18a72823          	sw	a0,400(a4)
}
22015658:	4501                	li	a0,0
2201565a:	8082                	ret

2201565c <GLB_GPIO_OUTPUT_Disable>:
    if(gpioPin>=32&&gpioPin<=37){
2201565c:	fe050713          	addi	a4,a0,-32
22015660:	0ff77693          	andi	a3,a4,255
22015664:	4795                	li	a5,5
22015666:	00d7ef63          	bltu	a5,a3,22015684 <GLB_GPIO_OUTPUT_Disable+0x28>
        if(BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO)&(1<<(gpioPin-32))){
2201566a:	400007b7          	lui	a5,0x40000
2201566e:	0887a683          	lw	a3,136(a5) # 40000088 <__ram_load_addr+0x1cff3164>
22015672:	4785                	li	a5,1
22015674:	00e797b3          	sll	a5,a5,a4
22015678:	8ff5                	and	a5,a5,a3
2201567a:	c789                	beqz	a5,22015684 <GLB_GPIO_OUTPUT_Disable+0x28>
            gpioPin-=9;
2201567c:	ff750793          	addi	a5,a0,-9
22015680:	0ff7f513          	andi	a0,a5,255
    tmpVal=BL_RD_REG(GLB_BASE,GLB_GPIO_CFGCTL34);
22015684:	40000737          	lui	a4,0x40000
22015688:	19072683          	lw	a3,400(a4) # 40000190 <__ram_load_addr+0x1cff326c>
    tmpVal=tmpVal&~(1<<gpioPin);
2201568c:	4785                	li	a5,1
2201568e:	00a797b3          	sll	a5,a5,a0
22015692:	fff7c793          	not	a5,a5
22015696:	8ff5                	and	a5,a5,a3
    BL_WR_REG(GLB_BASE,GLB_GPIO_CFGCTL34,tmpVal);
22015698:	18f72823          	sw	a5,400(a4)
}
2201569c:	4501                	li	a0,0
2201569e:	8082                	ret

220156a0 <GLB_GPIO_Set_HZ>:
    pOut=(uint32_t *)(GLB_BASE+GLB_GPIO_OUTPUT_EN_OFFSET+((gpioPin>>5)<<2));
220156a0:	40000737          	lui	a4,0x40000
220156a4:	00555693          	srli	a3,a0,0x5
220156a8:	19070793          	addi	a5,a4,400 # 40000190 <__ram_load_addr+0x1cff326c>
220156ac:	068a                	slli	a3,a3,0x2
220156ae:	96be                	add	a3,a3,a5
    tmpOut=*pOut;
220156b0:	4290                	lw	a2,0(a3)
    tmpOut &= (~(1<<pos));
220156b2:	4785                	li	a5,1
220156b4:	00a797b3          	sll	a5,a5,a0
220156b8:	fff7c793          	not	a5,a5
220156bc:	8ff1                	and	a5,a5,a2
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220156be:	00155613          	srli	a2,a0,0x1
220156c2:	10070713          	addi	a4,a4,256
220156c6:	060a                	slli	a2,a2,0x2
220156c8:	963a                	add	a2,a2,a4
    *pOut=tmpOut;
220156ca:	c29c                	sw	a5,0(a3)
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
220156cc:	4218                	lw	a4,0(a2)
    if(gpioPin%2==0){
220156ce:	00157593          	andi	a1,a0,1
220156d2:	e5b9                	bnez	a1,22015720 <GLB_GPIO_Set_HZ+0x80>
        tmpVal=(tmpVal&0xffff0000);
220156d4:	75c1                	lui	a1,0xffff0
220156d6:	8f6d                	and	a4,a4,a1
        tmpVal|=0x0B00;
220156d8:	6585                	lui	a1,0x1
220156da:	b0058593          	addi	a1,a1,-1280 # b00 <__metal_chicken_bit+0xb00>
        tmpVal|=(0x0B00<<16);
220156de:	8f4d                	or	a4,a4,a1
    BL_WR_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4,tmpVal);
220156e0:	c218                	sw	a4,0(a2)
    if(gpioPin>=9&&gpioPin<=13){
220156e2:	155d                	addi	a0,a0,-9
    *pOut=tmpOut;
220156e4:	c29c                	sw	a5,0(a3)
    if(gpioPin>=9&&gpioPin<=13){
220156e6:	0ff57713          	andi	a4,a0,255
220156ea:	4791                	li	a5,4
220156ec:	02e7e863          	bltu	a5,a4,2201571c <GLB_GPIO_Set_HZ+0x7c>
        tmpVal=BL_RD_REG(HBN_BASE,HBN_IRQ_MODE);
220156f0:	4000f637          	lui	a2,0x4000f
220156f4:	4a54                	lw	a3,20(a2)
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
220156f6:	7779                	lui	a4,0xffffe
220156f8:	0ff70793          	addi	a5,a4,255 # ffffe0ff <__HeapLimit+0xbdfd20ff>
220156fc:	00f6f733          	and	a4,a3,a5
        aonPadIeSmt&=~(1<<(gpioPin-9));
22015700:	4785                	li	a5,1
        aonPadIeSmt=BL_GET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT);
22015702:	82a1                	srli	a3,a3,0x8
        aonPadIeSmt&=~(1<<(gpioPin-9));
22015704:	00a797b3          	sll	a5,a5,a0
22015708:	fff7c793          	not	a5,a5
        tmpVal=BL_SET_REG_BITS_VAL(tmpVal,HBN_REG_AON_PAD_IE_SMT,aonPadIeSmt);
2201570c:	8ff5                	and	a5,a5,a3
2201570e:	6689                	lui	a3,0x2
22015710:	07a2                	slli	a5,a5,0x8
22015712:	f0068693          	addi	a3,a3,-256 # 1f00 <HeapSize+0xf00>
22015716:	8ff5                	and	a5,a5,a3
22015718:	8fd9                	or	a5,a5,a4
        BL_WR_REG(HBN_BASE,HBN_IRQ_MODE,tmpVal);
2201571a:	ca5c                	sw	a5,20(a2)
}
2201571c:	4501                	li	a0,0
2201571e:	8082                	ret
        tmpVal=(tmpVal&0x0000ffff);
22015720:	0742                	slli	a4,a4,0x10
22015722:	8341                	srli	a4,a4,0x10
        tmpVal|=(0x0B00<<16);
22015724:	0b0005b7          	lui	a1,0xb000
22015728:	bf5d                	j	220156de <GLB_GPIO_Set_HZ+0x3e>
    if(gpioPin>=32&&gpioPin<=37){
2201572a:	fe050713          	addi	a4,a0,-32
2201572e:	0ff77693          	andi	a3,a4,255
22015732:	4795                	li	a5,5
22015734:	00d7ee63          	bltu	a5,a3,22015750 <GLB_GPIO_Set_HZ+0xb0>
        if(BL_RD_REG(GLB_BASE,GLB_GPIO_USE_PSRAM__IO)&(1<<(gpioPin-32))){
22015738:	400007b7          	lui	a5,0x40000
2201573c:	0887a683          	lw	a3,136(a5) # 40000088 <__ram_load_addr+0x1cff3164>
22015740:	4785                	li	a5,1
22015742:	00e797b3          	sll	a5,a5,a4
22015746:	8ff5                	and	a5,a5,a3
22015748:	c781                	beqz	a5,22015750 <GLB_GPIO_Set_HZ+0xb0>
            gpioPin-=9;
2201574a:	155d                	addi	a0,a0,-9
2201574c:	0ff57513          	andi	a0,a0,255
    tmpVal=BL_RD_WORD(GLB_BASE+GLB_GPIO_OFFSET+gpioPin/2*4);
22015750:	00155793          	srli	a5,a0,0x1
22015754:	40000737          	lui	a4,0x40000
22015758:	078a                	slli	a5,a5,0x2
2201575a:	10070713          	addi	a4,a4,256 # 40000100 <__ram_load_addr+0x1cff31dc>
2201575e:	97ba                	add	a5,a5,a4
22015760:	439c                	lw	a5,0(a5)
    if(gpioPin%2==0){
22015762:	8905                	andi	a0,a0,1
22015764:	e509                	bnez	a0,2201576e <GLB_GPIO_Set_HZ+0xce>
        return BL_GET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_0_FUNC_SEL);
22015766:	83a1                	srli	a5,a5,0x8
        return BL_GET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL);
22015768:	01f7f513          	andi	a0,a5,31
}
2201576c:	8082                	ret
        return BL_GET_REG_BITS_VAL(tmpVal,GLB_REG_GPIO_1_FUNC_SEL);
2201576e:	83e1                	srli	a5,a5,0x18
22015770:	bfe5                	j	22015768 <GLB_GPIO_Set_HZ+0xc8>

22015772 <ASM_Delay_Us>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
void ASM_Delay_Us(uint32_t core,uint32_t cnt) {
    RomDriver_ASM_Delay_Us(core, cnt);
22015772:	210197b7          	lui	a5,0x21019
22015776:	8247a303          	lw	t1,-2012(a5) # 21018824 <HeapSize+0x21017824>
2201577a:	8302                	jr	t1

2201577c <BL702_Delay_US>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void BL702_Delay_US(uint32_t cnt) {
    RomDriver_BL702_Delay_US(cnt);
2201577c:	210197b7          	lui	a5,0x21019
22015780:	8287a303          	lw	t1,-2008(a5) # 21018828 <HeapSize+0x21017828>
22015784:	8302                	jr	t1

22015786 <BL702_Delay_MS>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void BL702_Delay_MS(uint32_t cnt) {
    RomDriver_BL702_Delay_MS(cnt);
22015786:	210197b7          	lui	a5,0x21019
2201578a:	82c7a303          	lw	t1,-2004(a5) # 2101882c <HeapSize+0x2101782c>
2201578e:	8302                	jr	t1

22015790 <arch_memcpy>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void* BL702_MemCpy(void *dst, const void *src, uint32_t n) {
    return RomDriver_BL702_MemCpy(dst, src, n);
22015790:	210197b7          	lui	a5,0x21019
22015794:	8307a303          	lw	t1,-2000(a5) # 21018830 <HeapSize+0x21017830>
22015798:	8302                	jr	t1

2201579a <arch_memcpy4>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t* BL702_MemCpy4(uint32_t *dst, const uint32_t *src, uint32_t n) {
    return RomDriver_BL702_MemCpy4(dst, src, n);
2201579a:	210197b7          	lui	a5,0x21019
2201579e:	8347a303          	lw	t1,-1996(a5) # 21018834 <HeapSize+0x21017834>
220157a2:	8302                	jr	t1

220157a4 <arch_memcpy_fast>:
//     return RomDriver_BL702_MemCpy_Fast(pdst, psrc, n);
// }

__ALWAYS_INLINE ATTR_TCM_SECTION
void* ARCH_MemCpy_Fast(void *pdst, const void *psrc, uint32_t n) {
    return RomDriver_ARCH_MemCpy_Fast(pdst, psrc, n);
220157a4:	210197b7          	lui	a5,0x21019
220157a8:	83c7a303          	lw	t1,-1988(a5) # 2101883c <HeapSize+0x2101783c>
220157ac:	8302                	jr	t1

220157ae <arch_memset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void* BL702_MemSet(void *s, uint8_t c, uint32_t n) {
    return RomDriver_BL702_MemSet(s, c, n);
220157ae:	210197b7          	lui	a5,0x21019
220157b2:	8407a303          	lw	t1,-1984(a5) # 21018840 <HeapSize+0x21017840>
220157b6:	8302                	jr	t1

220157b8 <arch_memset4>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t* BL702_MemSet4(uint32_t *dst, const uint32_t val, uint32_t n) {
    return RomDriver_BL702_MemSet4(dst, val, n);
220157b8:	210197b7          	lui	a5,0x21019
220157bc:	8447a303          	lw	t1,-1980(a5) # 21018844 <HeapSize+0x21017844>
220157c0:	8302                	jr	t1

220157c2 <arch_memcmp>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
int BL702_MemCmp(const void *s1, const void *s2, uint32_t n) {
    return RomDriver_BL702_MemCmp(s1, s2, n);
220157c2:	210197b7          	lui	a5,0x21019
220157c6:	8487a303          	lw	t1,-1976(a5) # 21018848 <HeapSize+0x21017848>
220157ca:	8302                	jr	t1

220157cc <BFLB_Soft_CRC32>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t BFLB_Soft_CRC32(void *dataIn, uint32_t len) {
    return RomDriver_BFLB_Soft_CRC32(dataIn, len);
220157cc:	210197b7          	lui	a5,0x21019
220157d0:	84c7a303          	lw	t1,-1972(a5) # 2101884c <HeapSize+0x2101784c>
220157d4:	8302                	jr	t1

220157d6 <GLB_SW_System_Reset>:
    return RomDriver_GLB_Disable_DLL_Clk(dllClk);
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_SW_System_Reset(void) {
    return RomDriver_GLB_SW_System_Reset();
220157d6:	210197b7          	lui	a5,0x21019
220157da:	8887a303          	lw	t1,-1912(a5) # 21018888 <HeapSize+0x21017888>
220157de:	8302                	jr	t1

220157e0 <GLB_SW_CPU_Reset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_SW_CPU_Reset(void) {
    return RomDriver_GLB_SW_CPU_Reset();
220157e0:	210197b7          	lui	a5,0x21019
220157e4:	88c7a303          	lw	t1,-1908(a5) # 2101888c <HeapSize+0x2101788c>
220157e8:	8302                	jr	t1

220157ea <GLB_SW_POR_Reset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_SW_POR_Reset(void) {
    return RomDriver_GLB_SW_POR_Reset();
220157ea:	210197b7          	lui	a5,0x21019
220157ee:	8907a303          	lw	t1,-1904(a5) # 21018890 <HeapSize+0x21017890>
220157f2:	8302                	jr	t1

220157f4 <GLB_Select_Internal_Flash>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Select_Internal_Flash(void) {
    return RomDriver_GLB_Select_Internal_Flash();
220157f4:	210197b7          	lui	a5,0x21019
220157f8:	8947a303          	lw	t1,-1900(a5) # 21018894 <HeapSize+0x21017894>
220157fc:	8302                	jr	t1

220157fe <GLB_Swap_Flash_Pin>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Swap_Flash_Pin(void) {
    return RomDriver_GLB_Swap_Flash_Pin();
220157fe:	210197b7          	lui	a5,0x21019
22015802:	8987a303          	lw	t1,-1896(a5) # 21018898 <HeapSize+0x21017898>
22015806:	8302                	jr	t1

22015808 <GLB_Swap_Flash_CS_IO2_Pin>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Swap_Flash_CS_IO2_Pin(void) {
    return RomDriver_GLB_Swap_Flash_CS_IO2_Pin();
22015808:	210197b7          	lui	a5,0x21019
2201580c:	89c7a303          	lw	t1,-1892(a5) # 2101889c <HeapSize+0x2101789c>
22015810:	8302                	jr	t1

22015812 <GLB_Swap_Flash_IO0_IO3_Pin>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Swap_Flash_IO0_IO3_Pin(void) {
    return RomDriver_GLB_Swap_Flash_IO0_IO3_Pin();
22015812:	210197b7          	lui	a5,0x21019
22015816:	8a07a303          	lw	t1,-1888(a5) # 210188a0 <HeapSize+0x210178a0>
2201581a:	8302                	jr	t1

2201581c <GLB_Select_Internal_PSram>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Select_Internal_PSram(void) {
    return RomDriver_GLB_Select_Internal_PSram();
2201581c:	210197b7          	lui	a5,0x21019
22015820:	8a47a303          	lw	t1,-1884(a5) # 210188a4 <HeapSize+0x210178a4>
22015824:	8302                	jr	t1

22015826 <GLB_Deswap_Flash_Pin>:
}
#endif

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Deswap_Flash_Pin(void) {
    return RomDriver_GLB_Deswap_Flash_Pin();
22015826:	210197b7          	lui	a5,0x21019
2201582a:	8b87a303          	lw	t1,-1864(a5) # 210188b8 <HeapSize+0x210178b8>
2201582e:	8302                	jr	t1

22015830 <GLB_Select_External_Flash>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type GLB_Select_External_Flash(void) {
    return RomDriver_GLB_Select_External_Flash();
22015830:	210197b7          	lui	a5,0x21019
22015834:	8bc7a303          	lw	t1,-1860(a5) # 210188bc <HeapSize+0x210178bc>
22015838:	8302                	jr	t1

2201583a <GLB_GPIO_Get_Fun>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint8_t GLB_GPIO_Get_Fun(GLB_GPIO_Type gpioPin) {
    return RomDriver_GLB_GPIO_Get_Fun(gpioPin);
2201583a:	210197b7          	lui	a5,0x21019
2201583e:	8c07a303          	lw	t1,-1856(a5) # 210188c0 <HeapSize+0x210178c0>
22015842:	8302                	jr	t1

22015844 <EF_Ctrl_Busy>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Sts_Type EF_Ctrl_Busy(void) {
    return RomDriver_EF_Ctrl_Busy();
22015844:	210197b7          	lui	a5,0x21019
22015848:	8c47a303          	lw	t1,-1852(a5) # 210188c4 <HeapSize+0x210178c4>
2201584c:	8302                	jr	t1

2201584e <EF_Ctrl_Sw_AHB_Clk_0>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void EF_Ctrl_Sw_AHB_Clk_0(void) {
    RomDriver_EF_Ctrl_Sw_AHB_Clk_0();
2201584e:	210197b7          	lui	a5,0x21019
22015852:	8c87a303          	lw	t1,-1848(a5) # 210188c8 <HeapSize+0x210178c8>
22015856:	8302                	jr	t1

22015858 <EF_Ctrl_Load_Efuse_R0>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void EF_Ctrl_Load_Efuse_R0(void) {
    RomDriver_EF_Ctrl_Load_Efuse_R0();
22015858:	210197b7          	lui	a5,0x21019
2201585c:	8cc7a303          	lw	t1,-1844(a5) # 210188cc <HeapSize+0x210178cc>
22015860:	8302                	jr	t1

22015862 <EF_Ctrl_Clear>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void EF_Ctrl_Clear(uint32_t index, uint32_t len) {
    RomDriver_EF_Ctrl_Clear(index, len);
22015862:	210197b7          	lui	a5,0x21019
22015866:	8d07a303          	lw	t1,-1840(a5) # 210188d0 <HeapSize+0x210178d0>
2201586a:	8302                	jr	t1

2201586c <PDS_Reset>:
    return RomDriver_PDS_Power_Off_PLL();
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Reset(void) {
    RomDriver_PDS_Reset();
2201586c:	210197b7          	lui	a5,0x21019
22015870:	9047a303          	lw	t1,-1788(a5) # 21018904 <HeapSize+0x21017904>
22015874:	8302                	jr	t1

22015876 <PDS_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Enable(PDS_CFG_Type *cfg,uint32_t pdsSleepCnt) {
    RomDriver_PDS_Enable(cfg, pdsSleepCnt);
22015876:	210197b7          	lui	a5,0x21019
2201587a:	9087a303          	lw	t1,-1784(a5) # 21018908 <HeapSize+0x21017908>
2201587e:	8302                	jr	t1

22015880 <PDS_Auto_Time_Config>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Auto_Time_Config(uint32_t sleepDuration) {
    RomDriver_PDS_Auto_Time_Config(sleepDuration);
22015880:	210197b7          	lui	a5,0x21019
22015884:	90c7a303          	lw	t1,-1780(a5) # 2101890c <HeapSize+0x2101790c>
22015888:	8302                	jr	t1

2201588a <PDS_Auto_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Auto_Enable(PDS_AUTO_POWER_DOWN_CFG_Type *powerCfg, PDS_AUTO_NORMAL_CFG_Type *normalCfg, BL_Fun_Type enable) {
    RomDriver_PDS_Auto_Enable(powerCfg, normalCfg, enable);
2201588a:	210197b7          	lui	a5,0x21019
2201588e:	9107a303          	lw	t1,-1776(a5) # 21018910 <HeapSize+0x21017910>
22015892:	8302                	jr	t1

22015894 <PDS_Manual_Force_Turn_Off>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Manual_Force_Turn_Off(PDS_FORCE_Type domain) {
    RomDriver_PDS_Manual_Force_Turn_Off(domain);
22015894:	210197b7          	lui	a5,0x21019
22015898:	9147a303          	lw	t1,-1772(a5) # 21018914 <HeapSize+0x21017914>
2201589c:	8302                	jr	t1

2201589e <PDS_Manual_Force_Turn_On>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void PDS_Manual_Force_Turn_On(PDS_FORCE_Type domain) {
    RomDriver_PDS_Manual_Force_Turn_On(domain);
2201589e:	210197b7          	lui	a5,0x21019
220158a2:	9187a303          	lw	t1,-1768(a5) # 21018918 <HeapSize+0x21017918>
220158a6:	8302                	jr	t1

220158a8 <HBN_Reset>:
}
#endif

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type HBN_Reset(void) {
    return RomDriver_HBN_Reset();
220158a8:	210197b7          	lui	a5,0x21019
220158ac:	9207a303          	lw	t1,-1760(a5) # 21018920 <HeapSize+0x21017920>
220158b0:	8302                	jr	t1

220158b2 <HBN_GPIO_Dbg_Pull_Cfg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type HBN_GPIO_Dbg_Pull_Cfg(BL_Fun_Type pupdEn,BL_Fun_Type dlyEn,uint8_t dlySec,HBN_INT_Type gpioIrq,BL_Mask_Type gpioMask) {
    return RomDriver_HBN_GPIO_Dbg_Pull_Cfg(pupdEn, dlyEn, dlySec, gpioIrq, gpioMask);
220158b2:	210197b7          	lui	a5,0x21019
220158b6:	9247a303          	lw	t1,-1756(a5) # 21018924 <HeapSize+0x21017924>
220158ba:	8302                	jr	t1

220158bc <XIP_SFlash_State_Save>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_State_Save(SPI_Flash_Cfg_Type *pFlashCfg,uint32_t *offset) {
    return RomDriver_XIP_SFlash_State_Save(pFlashCfg, offset);
220158bc:	210197b7          	lui	a5,0x21019
220158c0:	9307a303          	lw	t1,-1744(a5) # 21018930 <HeapSize+0x21017930>
220158c4:	8302                	jr	t1

220158c6 <XIP_SFlash_State_Restore>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_State_Restore(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t offset) {
    return RomDriver_XIP_SFlash_State_Restore(pFlashCfg, ioMode, offset);
220158c6:	210197b7          	lui	a5,0x21019
220158ca:	9347a303          	lw	t1,-1740(a5) # 21018934 <HeapSize+0x21017934>
220158ce:	8302                	jr	t1

220158d0 <XIP_SFlash_Erase_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_Erase_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t startaddr,uint32_t endaddr) {
    return RomDriver_XIP_SFlash_Erase_Need_Lock(pFlashCfg, ioMode, startaddr, endaddr);
220158d0:	210197b7          	lui	a5,0x21019
220158d4:	9387a303          	lw	t1,-1736(a5) # 21018938 <HeapSize+0x21017938>
220158d8:	8302                	jr	t1

220158da <XIP_SFlash_Write_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_Write_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t addr,uint8_t *data, uint32_t len) {
    return RomDriver_XIP_SFlash_Write_Need_Lock(pFlashCfg, ioMode, addr, data, len);
220158da:	210197b7          	lui	a5,0x21019
220158de:	93c7a303          	lw	t1,-1732(a5) # 2101893c <HeapSize+0x2101793c>
220158e2:	8302                	jr	t1

220158e4 <XIP_SFlash_Read_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_Read_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t addr,uint8_t *data, uint32_t len) {
    return RomDriver_XIP_SFlash_Read_Need_Lock(pFlashCfg, ioMode, addr, data, len);
220158e4:	210197b7          	lui	a5,0x21019
220158e8:	9407a303          	lw	t1,-1728(a5) # 21018940 <HeapSize+0x21017940>
220158ec:	8302                	jr	t1

220158ee <XIP_SFlash_GetJedecId_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_GetJedecId_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint8_t *data) {
    return RomDriver_XIP_SFlash_GetJedecId_Need_Lock(pFlashCfg, ioMode, data);
220158ee:	210197b7          	lui	a5,0x21019
220158f2:	9447a303          	lw	t1,-1724(a5) # 21018944 <HeapSize+0x21017944>
220158f6:	8302                	jr	t1

220158f8 <XIP_SFlash_GetDeviceId_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_GetDeviceId_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint8_t *data) {
    return RomDriver_XIP_SFlash_GetDeviceId_Need_Lock(pFlashCfg, ioMode, data);
220158f8:	210197b7          	lui	a5,0x21019
220158fc:	9487a303          	lw	t1,-1720(a5) # 21018948 <HeapSize+0x21017948>
22015900:	8302                	jr	t1

22015902 <XIP_SFlash_GetUniqueId_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_GetUniqueId_Need_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint8_t *data,uint8_t idLen) {
    return RomDriver_XIP_SFlash_GetUniqueId_Need_Lock(pFlashCfg, ioMode, data, idLen);
22015902:	210197b7          	lui	a5,0x21019
22015906:	94c7a303          	lw	t1,-1716(a5) # 2101894c <HeapSize+0x2101794c>
2201590a:	8302                	jr	t1

2201590c <XIP_SFlash_Read_Via_Cache_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type XIP_SFlash_Read_Via_Cache_Need_Lock(uint32_t addr,uint8_t *data, uint32_t len) {
    return RomDriver_XIP_SFlash_Read_Via_Cache_Need_Lock(addr, data, len);
2201590c:	210197b7          	lui	a5,0x21019
22015910:	9507a303          	lw	t1,-1712(a5) # 21018950 <HeapSize+0x21017950>
22015914:	8302                	jr	t1

22015916 <XIP_SFlash_Read_With_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
int XIP_SFlash_Read_With_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t addr, uint8_t *dst, int len) {
    return RomDriver_XIP_SFlash_Read_With_Lock(pFlashCfg, ioMode, addr, dst, len);
22015916:	210197b7          	lui	a5,0x21019
2201591a:	9547a303          	lw	t1,-1708(a5) # 21018954 <HeapSize+0x21017954>
2201591e:	8302                	jr	t1

22015920 <XIP_SFlash_Write_With_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
int XIP_SFlash_Write_With_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t addr, uint8_t *src, int len) {
    return RomDriver_XIP_SFlash_Write_With_Lock(pFlashCfg, ioMode, addr, src, len);
22015920:	210197b7          	lui	a5,0x21019
22015924:	9587a303          	lw	t1,-1704(a5) # 21018958 <HeapSize+0x21017958>
22015928:	8302                	jr	t1

2201592a <XIP_SFlash_Erase_With_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
int XIP_SFlash_Erase_With_Lock(SPI_Flash_Cfg_Type *pFlashCfg,SF_Ctrl_IO_Type ioMode,uint32_t addr, int len) {
    return RomDriver_XIP_SFlash_Erase_With_Lock(pFlashCfg, ioMode, addr, len);
2201592a:	210197b7          	lui	a5,0x21019
2201592e:	95c7a303          	lw	t1,-1700(a5) # 2101895c <HeapSize+0x2101795c>
22015932:	8302                	jr	t1

22015934 <SFlash_Init>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Init(const SF_Ctrl_Cfg_Type *pSfCtrlCfg) {
    RomDriver_SFlash_Init(pSfCtrlCfg);
22015934:	210197b7          	lui	a5,0x21019
22015938:	9607a303          	lw	t1,-1696(a5) # 21018960 <HeapSize+0x21017960>
2201593c:	8302                	jr	t1

2201593e <SFlash_SetSPIMode>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_SetSPIMode(SF_Ctrl_Mode_Type mode) {
    return RomDriver_SFlash_SetSPIMode(mode);
2201593e:	210197b7          	lui	a5,0x21019
22015942:	9647a303          	lw	t1,-1692(a5) # 21018964 <HeapSize+0x21017964>
22015946:	8302                	jr	t1

22015948 <SFlash_Read_Reg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Read_Reg(SPI_Flash_Cfg_Type *flashCfg,uint8_t regIndex,uint8_t *regValue,uint8_t regLen) {
    return RomDriver_SFlash_Read_Reg(flashCfg, regIndex, regValue, regLen);
22015948:	210197b7          	lui	a5,0x21019
2201594c:	9687a303          	lw	t1,-1688(a5) # 21018968 <HeapSize+0x21017968>
22015950:	8302                	jr	t1

22015952 <SFlash_Write_Reg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Write_Reg(SPI_Flash_Cfg_Type *flashCfg,uint8_t regIndex,uint8_t *regValue,uint8_t regLen) {
    return RomDriver_SFlash_Write_Reg(flashCfg, regIndex, regValue, regLen);
22015952:	210197b7          	lui	a5,0x21019
22015956:	96c7a303          	lw	t1,-1684(a5) # 2101896c <HeapSize+0x2101796c>
2201595a:	8302                	jr	t1

2201595c <SFlash_Read_Reg_With_Cmd>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Read_Reg_With_Cmd(SPI_Flash_Cfg_Type *flashCfg,uint8_t readRegCmd,uint8_t *regValue,uint8_t regLen) {
    return RomDriver_SFlash_Read_Reg_With_Cmd(flashCfg, readRegCmd, regValue, regLen);
2201595c:	210197b7          	lui	a5,0x21019
22015960:	9707a303          	lw	t1,-1680(a5) # 21018970 <HeapSize+0x21017970>
22015964:	8302                	jr	t1

22015966 <SFlash_Write_Reg_With_Cmd>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Write_Reg_With_Cmd(SPI_Flash_Cfg_Type *flashCfg,uint8_t writeRegCmd,uint8_t *regValue,uint8_t regLen) {
    return RomDriver_SFlash_Write_Reg_With_Cmd(flashCfg, writeRegCmd, regValue, regLen);
22015966:	210197b7          	lui	a5,0x21019
2201596a:	9747a303          	lw	t1,-1676(a5) # 21018974 <HeapSize+0x21017974>
2201596e:	8302                	jr	t1

22015970 <SFlash_Busy>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Sts_Type SFlash_Busy(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Busy(flashCfg);
22015970:	210197b7          	lui	a5,0x21019
22015974:	9787a303          	lw	t1,-1672(a5) # 21018978 <HeapSize+0x21017978>
22015978:	8302                	jr	t1

2201597a <SFlash_Write_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Write_Enable(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Write_Enable(flashCfg);
2201597a:	210197b7          	lui	a5,0x21019
2201597e:	97c7a303          	lw	t1,-1668(a5) # 2101897c <HeapSize+0x2101797c>
22015982:	8302                	jr	t1

22015984 <SFlash_Qspi_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Qspi_Enable(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Qspi_Enable(flashCfg);
22015984:	210197b7          	lui	a5,0x21019
22015988:	9807a303          	lw	t1,-1664(a5) # 21018980 <HeapSize+0x21017980>
2201598c:	8302                	jr	t1

2201598e <SFlash_Volatile_Reg_Write_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Volatile_Reg_Write_Enable(SPI_Flash_Cfg_Type *flashCfg) {
    RomDriver_SFlash_Volatile_Reg_Write_Enable(flashCfg);
2201598e:	210197b7          	lui	a5,0x21019
22015992:	9847a303          	lw	t1,-1660(a5) # 21018984 <HeapSize+0x21017984>
22015996:	8302                	jr	t1

22015998 <SFlash_Chip_Erase>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Chip_Erase(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Chip_Erase(flashCfg);
22015998:	210197b7          	lui	a5,0x21019
2201599c:	9887a303          	lw	t1,-1656(a5) # 21018988 <HeapSize+0x21017988>
220159a0:	8302                	jr	t1

220159a2 <SFlash_Sector_Erase>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Sector_Erase(SPI_Flash_Cfg_Type *flashCfg,uint32_t secNum) {
    return RomDriver_SFlash_Sector_Erase(flashCfg, secNum);
220159a2:	210197b7          	lui	a5,0x21019
220159a6:	98c7a303          	lw	t1,-1652(a5) # 2101898c <HeapSize+0x2101798c>
220159aa:	8302                	jr	t1

220159ac <SFlash_Blk32_Erase>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Blk32_Erase(SPI_Flash_Cfg_Type *flashCfg,uint32_t blkNum) {
    return RomDriver_SFlash_Blk32_Erase(flashCfg, blkNum);
220159ac:	210197b7          	lui	a5,0x21019
220159b0:	9907a303          	lw	t1,-1648(a5) # 21018990 <HeapSize+0x21017990>
220159b4:	8302                	jr	t1

220159b6 <SFlash_Blk64_Erase>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Blk64_Erase(SPI_Flash_Cfg_Type *flashCfg,uint32_t blkNum) {
    return RomDriver_SFlash_Blk64_Erase(flashCfg, blkNum);
220159b6:	210197b7          	lui	a5,0x21019
220159ba:	9947a303          	lw	t1,-1644(a5) # 21018994 <HeapSize+0x21017994>
220159be:	8302                	jr	t1

220159c0 <SFlash_Erase>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Erase(SPI_Flash_Cfg_Type *flashCfg,uint32_t startaddr,uint32_t endaddr) {
    return RomDriver_SFlash_Erase(flashCfg, startaddr, endaddr);
220159c0:	210197b7          	lui	a5,0x21019
220159c4:	9987a303          	lw	t1,-1640(a5) # 21018998 <HeapSize+0x21017998>
220159c8:	8302                	jr	t1

220159ca <SFlash_Program>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Program(SPI_Flash_Cfg_Type *flashCfg, SF_Ctrl_IO_Type ioMode,uint32_t addr,uint8_t *data, uint32_t len) {
    return RomDriver_SFlash_Program(flashCfg, ioMode, addr, data, len);
220159ca:	210197b7          	lui	a5,0x21019
220159ce:	99c7a303          	lw	t1,-1636(a5) # 2101899c <HeapSize+0x2101799c>
220159d2:	8302                	jr	t1

220159d4 <SFlash_GetUniqueId>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_GetUniqueId(uint8_t *data,uint8_t idLen) {
    RomDriver_SFlash_GetUniqueId(data, idLen);
220159d4:	210197b7          	lui	a5,0x21019
220159d8:	9a07a303          	lw	t1,-1632(a5) # 210189a0 <HeapSize+0x210179a0>
220159dc:	8302                	jr	t1

220159de <SFlash_GetJedecId>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_GetJedecId(SPI_Flash_Cfg_Type *flashCfg,uint8_t *data) {
    RomDriver_SFlash_GetJedecId(flashCfg, data);
220159de:	210197b7          	lui	a5,0x21019
220159e2:	9a47a303          	lw	t1,-1628(a5) # 210189a4 <HeapSize+0x210179a4>
220159e6:	8302                	jr	t1

220159e8 <SFlash_GetDeviceId>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_GetDeviceId(uint8_t *data) {
    RomDriver_SFlash_GetDeviceId(data);
220159e8:	210197b7          	lui	a5,0x21019
220159ec:	9a87a303          	lw	t1,-1624(a5) # 210189a8 <HeapSize+0x210179a8>
220159f0:	8302                	jr	t1

220159f2 <SFlash_Powerdown>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Powerdown(void) {
    RomDriver_SFlash_Powerdown();
220159f2:	210197b7          	lui	a5,0x21019
220159f6:	9ac7a303          	lw	t1,-1620(a5) # 210189ac <HeapSize+0x210179ac>
220159fa:	8302                	jr	t1

220159fc <SFlash_Releae_Powerdown>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Releae_Powerdown(SPI_Flash_Cfg_Type *flashCfg) {
    RomDriver_SFlash_Releae_Powerdown(flashCfg);
220159fc:	210197b7          	lui	a5,0x21019
22015a00:	9b07a303          	lw	t1,-1616(a5) # 210189b0 <HeapSize+0x210179b0>
22015a04:	8302                	jr	t1

22015a06 <SFlash_Restore_From_Powerdown>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Restore_From_Powerdown(SPI_Flash_Cfg_Type *pFlashCfg,uint8_t flashContRead) {
    return RomDriver_SFlash_Restore_From_Powerdown(pFlashCfg, flashContRead);
22015a06:	210197b7          	lui	a5,0x21019
22015a0a:	9b47a303          	lw	t1,-1612(a5) # 210189b4 <HeapSize+0x210179b4>
22015a0e:	8302                	jr	t1

22015a10 <SFlash_SetBurstWrap>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_SetBurstWrap(SPI_Flash_Cfg_Type *flashCfg) {
    RomDriver_SFlash_SetBurstWrap(flashCfg);
22015a10:	210197b7          	lui	a5,0x21019
22015a14:	9b87a303          	lw	t1,-1608(a5) # 210189b8 <HeapSize+0x210179b8>
22015a18:	8302                	jr	t1

22015a1a <SFlash_DisableBurstWrap>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_DisableBurstWrap(SPI_Flash_Cfg_Type *flashCfg) {
    RomDriver_SFlash_DisableBurstWrap(flashCfg);
22015a1a:	210197b7          	lui	a5,0x21019
22015a1e:	9bc7a303          	lw	t1,-1604(a5) # 210189bc <HeapSize+0x210179bc>
22015a22:	8302                	jr	t1

22015a24 <SFlash_Software_Reset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Software_Reset(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Software_Reset(flashCfg);
22015a24:	210197b7          	lui	a5,0x21019
22015a28:	9c07a303          	lw	t1,-1600(a5) # 210189c0 <HeapSize+0x210179c0>
22015a2c:	8302                	jr	t1

22015a2e <SFlash_Reset_Continue_Read>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Reset_Continue_Read(SPI_Flash_Cfg_Type *flashCfg) {
    return RomDriver_SFlash_Reset_Continue_Read(flashCfg);
22015a2e:	210197b7          	lui	a5,0x21019
22015a32:	9c47a303          	lw	t1,-1596(a5) # 210189c4 <HeapSize+0x210179c4>
22015a36:	8302                	jr	t1

22015a38 <SFlash_Set_IDbus_Cfg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Set_IDbus_Cfg(SPI_Flash_Cfg_Type *flashCfg,
    SF_Ctrl_IO_Type ioMode,uint8_t contRead,uint32_t addr,uint32_t len) {
    return RomDriver_SFlash_Set_IDbus_Cfg(flashCfg, ioMode, contRead, addr, len);
22015a38:	210197b7          	lui	a5,0x21019
22015a3c:	9c87a303          	lw	t1,-1592(a5) # 210189c8 <HeapSize+0x210179c8>
22015a40:	8302                	jr	t1

22015a42 <SFlash_IDbus_Read_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_IDbus_Read_Enable(SPI_Flash_Cfg_Type *flashCfg,SF_Ctrl_IO_Type ioMode,uint8_t contRead) {
    return RomDriver_SFlash_IDbus_Read_Enable(flashCfg, ioMode, contRead);
22015a42:	210197b7          	lui	a5,0x21019
22015a46:	9cc7a303          	lw	t1,-1588(a5) # 210189cc <HeapSize+0x210179cc>
22015a4a:	8302                	jr	t1

22015a4c <SFlash_Cache_Read_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Cache_Read_Enable(SPI_Flash_Cfg_Type *flashCfg,
    SF_Ctrl_IO_Type ioMode,uint8_t contRead,uint8_t wayDisable) {
    return RomDriver_SFlash_Cache_Read_Enable(flashCfg, ioMode, contRead, wayDisable);
22015a4c:	210197b7          	lui	a5,0x21019
22015a50:	9d07a303          	lw	t1,-1584(a5) # 210189d0 <HeapSize+0x210179d0>
22015a54:	8302                	jr	t1

22015a56 <SFlash_Cache_Read_Disable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SFlash_Cache_Read_Disable(void) {
    RomDriver_SFlash_Cache_Read_Disable();
22015a56:	210197b7          	lui	a5,0x21019
22015a5a:	9d47a303          	lw	t1,-1580(a5) # 210189d4 <HeapSize+0x210179d4>
22015a5e:	8302                	jr	t1

22015a60 <SFlash_Read>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SFlash_Read(SPI_Flash_Cfg_Type *flashCfg,
    SF_Ctrl_IO_Type ioMode,uint8_t contRead,uint32_t addr,uint8_t *data, uint32_t len) {
    return RomDriver_SFlash_Read(flashCfg, ioMode, contRead, addr, data, len);
22015a60:	21019837          	lui	a6,0x21019
22015a64:	9d882303          	lw	t1,-1576(a6) # 210189d8 <HeapSize+0x210179d8>
22015a68:	8302                	jr	t1

22015a6a <L1C_Cache_Enable_Set>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type L1C_Cache_Enable_Set(uint8_t wayDisable) {
    return RomDriver_L1C_Cache_Enable_Set(wayDisable);
22015a6a:	210197b7          	lui	a5,0x21019
22015a6e:	9dc7a303          	lw	t1,-1572(a5) # 210189dc <HeapSize+0x210179dc>
22015a72:	8302                	jr	t1

22015a74 <L1C_Cache_Write_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void L1C_Cache_Write_Set(BL_Fun_Type wtEn, BL_Fun_Type wbEn, BL_Fun_Type waEn) {
    RomDriver_L1C_Cache_Write_Set(wtEn, wbEn, waEn);
22015a74:	210197b7          	lui	a5,0x21019
22015a78:	9e07a303          	lw	t1,-1568(a5) # 210189e0 <HeapSize+0x210179e0>
22015a7c:	8302                	jr	t1

22015a7e <L1C_Cache_Flush>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type L1C_Cache_Flush(uint8_t wayDisable) {
    return RomDriver_L1C_Cache_Flush(wayDisable);
22015a7e:	210197b7          	lui	a5,0x21019
22015a82:	9e47a303          	lw	t1,-1564(a5) # 210189e4 <HeapSize+0x210179e4>
22015a86:	8302                	jr	t1

22015a88 <L1C_Cache_Hit_Count_Get>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void L1C_Cache_Hit_Count_Get(uint32_t *hitCountLow,uint32_t *hitCountHigh) {
    RomDriver_L1C_Cache_Hit_Count_Get(hitCountLow, hitCountHigh);
22015a88:	210197b7          	lui	a5,0x21019
22015a8c:	9e87a303          	lw	t1,-1560(a5) # 210189e8 <HeapSize+0x210179e8>
22015a90:	8302                	jr	t1

22015a92 <L1C_Cache_Miss_Count_Get>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t L1C_Cache_Miss_Count_Get(void) {
    return RomDriver_L1C_Cache_Miss_Count_Get();
22015a92:	210197b7          	lui	a5,0x21019
22015a96:	9ec7a303          	lw	t1,-1556(a5) # 210189ec <HeapSize+0x210179ec>
22015a9a:	8302                	jr	t1

22015a9c <L1C_Cache_Read_Disable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void L1C_Cache_Read_Disable(void) {
    RomDriver_L1C_Cache_Read_Disable();
22015a9c:	210197b7          	lui	a5,0x21019
22015aa0:	9f07a303          	lw	t1,-1552(a5) # 210189f0 <HeapSize+0x210179f0>
22015aa4:	8302                	jr	t1

22015aa6 <L1C_Set_Wrap>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type L1C_Set_Wrap(BL_Fun_Type wrap) {
    return RomDriver_L1C_Set_Wrap(wrap);
22015aa6:	210197b7          	lui	a5,0x21019
22015aaa:	9f47a303          	lw	t1,-1548(a5) # 210189f4 <HeapSize+0x210179f4>
22015aae:	8302                	jr	t1

22015ab0 <L1C_Set_Way_Disable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type L1C_Set_Way_Disable(uint8_t disableVal) {
    return RomDriver_L1C_Set_Way_Disable(disableVal);
22015ab0:	210197b7          	lui	a5,0x21019
22015ab4:	9f87a303          	lw	t1,-1544(a5) # 210189f8 <HeapSize+0x210179f8>
22015ab8:	8302                	jr	t1

22015aba <L1C_IROM_2T_Access_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type L1C_IROM_2T_Access_Set(uint8_t enable) {
    return RomDriver_L1C_IROM_2T_Access_Set(enable);
22015aba:	210197b7          	lui	a5,0x21019
22015abe:	9fc7a303          	lw	t1,-1540(a5) # 210189fc <HeapSize+0x210179fc>
22015ac2:	8302                	jr	t1

22015ac4 <SF_Ctrl_Enable>:
/******************************************************************************/

/******************************************************************************/
__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Enable(const SF_Ctrl_Cfg_Type *cfg) {
    RomDriver_SF_Ctrl_Enable(cfg);
22015ac4:	210197b7          	lui	a5,0x21019
22015ac8:	a007a303          	lw	t1,-1536(a5) # 21018a00 <HeapSize+0x21017a00>
22015acc:	8302                	jr	t1

22015ace <SF_Ctrl_Get_Clock_Delay>:
}
#endif

__ALWAYS_INLINE ATTR_TCM_SECTION
uint8_t SF_Ctrl_Get_Clock_Delay(void) {
    return RomDriver_SF_Ctrl_Get_Clock_Delay();
22015ace:	210197b7          	lui	a5,0x21019
22015ad2:	a087a303          	lw	t1,-1528(a5) # 21018a08 <HeapSize+0x21017a08>
22015ad6:	8302                	jr	t1

22015ad8 <SF_Ctrl_Set_Clock_Delay>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Set_Clock_Delay(uint8_t delay) {
    RomDriver_SF_Ctrl_Set_Clock_Delay(delay);
22015ad8:	210197b7          	lui	a5,0x21019
22015adc:	a0c7a303          	lw	t1,-1524(a5) # 21018a0c <HeapSize+0x21017a0c>
22015ae0:	8302                	jr	t1

22015ae2 <SF_Ctrl_Cmds_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Cmds_Set(SF_Ctrl_Cmds_Cfg *cmdsCfg) {
    RomDriver_SF_Ctrl_Cmds_Set(cmdsCfg);
22015ae2:	210197b7          	lui	a5,0x21019
22015ae6:	a107a303          	lw	t1,-1520(a5) # 21018a10 <HeapSize+0x21017a10>
22015aea:	8302                	jr	t1

22015aec <SF_Ctrl_Set_Owner>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Set_Owner(SF_Ctrl_Owner_Type owner) {
    RomDriver_SF_Ctrl_Set_Owner(owner);
22015aec:	210197b7          	lui	a5,0x21019
22015af0:	a147a303          	lw	t1,-1516(a5) # 21018a14 <HeapSize+0x21017a14>
22015af4:	8302                	jr	t1

22015af6 <SF_Ctrl_Disable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Disable(void) {
    RomDriver_SF_Ctrl_Disable();
22015af6:	210197b7          	lui	a5,0x21019
22015afa:	a187a303          	lw	t1,-1512(a5) # 21018a18 <HeapSize+0x21017a18>
22015afe:	8302                	jr	t1

22015b00 <SF_Ctrl_Select_Pad>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Select_Pad(SF_Ctrl_Pad_Select sel) {
    RomDriver_SF_Ctrl_Select_Pad(sel);
22015b00:	210197b7          	lui	a5,0x21019
22015b04:	a1c7a303          	lw	t1,-1508(a5) # 21018a1c <HeapSize+0x21017a1c>
22015b08:	8302                	jr	t1

22015b0a <SF_Ctrl_Select_Bank>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Select_Bank(SF_Ctrl_Select sel) {
    RomDriver_SF_Ctrl_Select_Bank(sel);
22015b0a:	210197b7          	lui	a5,0x21019
22015b0e:	a207a303          	lw	t1,-1504(a5) # 21018a20 <HeapSize+0x21017a20>
22015b12:	8302                	jr	t1

22015b14 <SF_Ctrl_AES_Enable_BE>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Enable_BE(void) {
    RomDriver_SF_Ctrl_AES_Enable_BE();
22015b14:	210197b7          	lui	a5,0x21019
22015b18:	a247a303          	lw	t1,-1500(a5) # 21018a24 <HeapSize+0x21017a24>
22015b1c:	8302                	jr	t1

22015b1e <SF_Ctrl_AES_Enable_LE>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Enable_LE(void) {
    RomDriver_SF_Ctrl_AES_Enable_LE();
22015b1e:	210197b7          	lui	a5,0x21019
22015b22:	a287a303          	lw	t1,-1496(a5) # 21018a28 <HeapSize+0x21017a28>
22015b26:	8302                	jr	t1

22015b28 <SF_Ctrl_AES_Set_Region>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Set_Region(uint8_t region,uint8_t enable,
    uint8_t hwKey,uint32_t startAddr,uint32_t endAddr,uint8_t locked) {
    RomDriver_SF_Ctrl_AES_Set_Region(region, enable, hwKey, startAddr, endAddr, locked);
22015b28:	21019837          	lui	a6,0x21019
22015b2c:	a2c82303          	lw	t1,-1492(a6) # 21018a2c <HeapSize+0x21017a2c>
22015b30:	8302                	jr	t1

22015b32 <SF_Ctrl_AES_Set_Key>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Set_Key(uint8_t region,uint8_t *key, SF_Ctrl_AES_Key_Type keyType) {
    RomDriver_SF_Ctrl_AES_Set_Key(region, key, keyType);
22015b32:	210197b7          	lui	a5,0x21019
22015b36:	a307a303          	lw	t1,-1488(a5) # 21018a30 <HeapSize+0x21017a30>
22015b3a:	8302                	jr	t1

22015b3c <SF_Ctrl_AES_Set_Key_BE>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Set_Key_BE(uint8_t region,uint8_t *key, SF_Ctrl_AES_Key_Type keyType) {
    RomDriver_SF_Ctrl_AES_Set_Key_BE(region, key, keyType);
22015b3c:	210197b7          	lui	a5,0x21019
22015b40:	a347a303          	lw	t1,-1484(a5) # 21018a34 <HeapSize+0x21017a34>
22015b44:	8302                	jr	t1

22015b46 <SF_Ctrl_AES_Set_IV>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Set_IV(uint8_t region,uint8_t *iv,uint32_t addrOffset) {
    RomDriver_SF_Ctrl_AES_Set_IV(region, iv, addrOffset);
22015b46:	210197b7          	lui	a5,0x21019
22015b4a:	a387a303          	lw	t1,-1480(a5) # 21018a38 <HeapSize+0x21017a38>
22015b4e:	8302                	jr	t1

22015b50 <SF_Ctrl_AES_Set_IV_BE>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Set_IV_BE(uint8_t region,uint8_t *iv,uint32_t addrOffset) {
    RomDriver_SF_Ctrl_AES_Set_IV_BE(region, iv, addrOffset);
22015b50:	210197b7          	lui	a5,0x21019
22015b54:	a3c7a303          	lw	t1,-1476(a5) # 21018a3c <HeapSize+0x21017a3c>
22015b58:	8302                	jr	t1

22015b5a <SF_Ctrl_AES_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Enable(void) {
    RomDriver_SF_Ctrl_AES_Enable();
22015b5a:	210197b7          	lui	a5,0x21019
22015b5e:	a407a303          	lw	t1,-1472(a5) # 21018a40 <HeapSize+0x21017a40>
22015b62:	8302                	jr	t1

22015b64 <SF_Ctrl_AES_Disable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_AES_Disable(void) {
    RomDriver_SF_Ctrl_AES_Disable();
22015b64:	210197b7          	lui	a5,0x21019
22015b68:	a447a303          	lw	t1,-1468(a5) # 21018a44 <HeapSize+0x21017a44>
22015b6c:	8302                	jr	t1

22015b6e <SF_Ctrl_Is_AES_Enable>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint8_t SF_Ctrl_Is_AES_Enable(void) {
    return RomDriver_SF_Ctrl_Is_AES_Enable();
22015b6e:	210197b7          	lui	a5,0x21019
22015b72:	a487a303          	lw	t1,-1464(a5) # 21018a48 <HeapSize+0x21017a48>
22015b76:	8302                	jr	t1

22015b78 <SF_Ctrl_Set_Flash_Image_Offset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Set_Flash_Image_Offset(uint32_t addrOffset) {
    RomDriver_SF_Ctrl_Set_Flash_Image_Offset(addrOffset);
22015b78:	210197b7          	lui	a5,0x21019
22015b7c:	a4c7a303          	lw	t1,-1460(a5) # 21018a4c <HeapSize+0x21017a4c>
22015b80:	8302                	jr	t1

22015b82 <SF_Ctrl_Get_Flash_Image_Offset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t SF_Ctrl_Get_Flash_Image_Offset(void) {
    return RomDriver_SF_Ctrl_Get_Flash_Image_Offset();
22015b82:	210197b7          	lui	a5,0x21019
22015b86:	a507a303          	lw	t1,-1456(a5) # 21018a50 <HeapSize+0x21017a50>
22015b8a:	8302                	jr	t1

22015b8c <SF_Ctrl_Select_Clock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Select_Clock(SF_Ctrl_Sahb_Type sahbType) {
    RomDriver_SF_Ctrl_Select_Clock(sahbType);
22015b8c:	210197b7          	lui	a5,0x21019
22015b90:	a547a303          	lw	t1,-1452(a5) # 21018a54 <HeapSize+0x21017a54>
22015b94:	8302                	jr	t1

22015b96 <SF_Ctrl_SendCmd>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_SendCmd(SF_Ctrl_Cmd_Cfg_Type *cfg) {
    RomDriver_SF_Ctrl_SendCmd(cfg);
22015b96:	210197b7          	lui	a5,0x21019
22015b9a:	a587a303          	lw	t1,-1448(a5) # 21018a58 <HeapSize+0x21017a58>
22015b9e:	8302                	jr	t1

22015ba0 <SF_Ctrl_Flash_Read_Icache_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Flash_Read_Icache_Set(SF_Ctrl_Cmd_Cfg_Type *cfg,uint8_t cmdValid) {
    RomDriver_SF_Ctrl_Flash_Read_Icache_Set(cfg, cmdValid);
22015ba0:	210197b7          	lui	a5,0x21019
22015ba4:	a5c7a303          	lw	t1,-1444(a5) # 21018a5c <HeapSize+0x21017a5c>
22015ba8:	8302                	jr	t1

22015baa <SF_Ctrl_Psram_Write_Icache_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Psram_Write_Icache_Set(SF_Ctrl_Cmd_Cfg_Type *cfg,uint8_t cmdValid) {
    RomDriver_SF_Ctrl_Psram_Write_Icache_Set(cfg, cmdValid);
22015baa:	210197b7          	lui	a5,0x21019
22015bae:	a607a303          	lw	t1,-1440(a5) # 21018a60 <HeapSize+0x21017a60>
22015bb2:	8302                	jr	t1

22015bb4 <SF_Ctrl_Psram_Read_Icache_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Ctrl_Psram_Read_Icache_Set(SF_Ctrl_Cmd_Cfg_Type *cfg,uint8_t cmdValid) {
    RomDriver_SF_Ctrl_Psram_Read_Icache_Set(cfg, cmdValid);
22015bb4:	210197b7          	lui	a5,0x21019
22015bb8:	a647a303          	lw	t1,-1436(a5) # 21018a64 <HeapSize+0x21017a64>
22015bbc:	8302                	jr	t1

22015bbe <SF_Ctrl_GetBusyState>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Sts_Type SF_Ctrl_GetBusyState(void) {
    return RomDriver_SF_Ctrl_GetBusyState();
22015bbe:	210197b7          	lui	a5,0x21019
22015bc2:	a687a303          	lw	t1,-1432(a5) # 21018a68 <HeapSize+0x21017a68>
22015bc6:	8302                	jr	t1

22015bc8 <SF_Cfg_Deinit_Ext_Flash_Gpio>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Cfg_Deinit_Ext_Flash_Gpio(uint8_t extFlashPin) {
    RomDriver_SF_Cfg_Deinit_Ext_Flash_Gpio(extFlashPin);
22015bc8:	210197b7          	lui	a5,0x21019
22015bcc:	a6c7a303          	lw	t1,-1428(a5) # 21018a6c <HeapSize+0x21017a6c>
22015bd0:	8302                	jr	t1

22015bd2 <SF_Cfg_Init_Ext_Flash_Gpio>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void SF_Cfg_Init_Ext_Flash_Gpio(uint8_t extFlashPin) {
    RomDriver_SF_Cfg_Init_Ext_Flash_Gpio(extFlashPin);
22015bd2:	210197b7          	lui	a5,0x21019
22015bd6:	a707a303          	lw	t1,-1424(a5) # 21018a70 <HeapSize+0x21017a70>
22015bda:	8302                	jr	t1

22015bdc <SF_Cfg_Get_Flash_Cfg_Need_Lock>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type SF_Cfg_Get_Flash_Cfg_Need_Lock(uint32_t flashID,SPI_Flash_Cfg_Type * pFlashCfg) {
    return RomDriver_SF_Cfg_Get_Flash_Cfg_Need_Lock(flashID, pFlashCfg);
22015bdc:	210197b7          	lui	a5,0x21019
22015be0:	a747a303          	lw	t1,-1420(a5) # 21018a74 <HeapSize+0x21017a74>
22015be4:	8302                	jr	t1

22015be6 <SF_Cfg_Flash_Identify>:
#endif

__ALWAYS_INLINE ATTR_TCM_SECTION
uint32_t SF_Cfg_Flash_Identify(uint8_t callFromFlash,uint32_t autoScan,uint32_t flashPinCfg,uint8_t restoreDefault,
    SPI_Flash_Cfg_Type * pFlashCfg) {
    return RomDriver_SF_Cfg_Flash_Identify(callFromFlash, autoScan, flashPinCfg, restoreDefault, pFlashCfg);
22015be6:	210197b7          	lui	a5,0x21019
22015bea:	a7c7a303          	lw	t1,-1412(a5) # 21018a7c <HeapSize+0x21017a7c>
22015bee:	8302                	jr	t1

22015bf0 <Psram_ReadReg>:
}
#endif

__ALWAYS_INLINE ATTR_TCM_SECTION
void Psram_ReadReg(SPI_Psram_Cfg_Type *psramCfg, uint8_t *regValue) {
    RomDriver_Psram_ReadReg(psramCfg, regValue);
22015bf0:	210197b7          	lui	a5,0x21019
22015bf4:	a847a303          	lw	t1,-1404(a5) # 21018a84 <HeapSize+0x21017a84>
22015bf8:	8302                	jr	t1

22015bfa <Psram_WriteReg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void Psram_WriteReg(SPI_Psram_Cfg_Type *psramCfg, uint8_t *regValue) {
    RomDriver_Psram_WriteReg(psramCfg, regValue);
22015bfa:	210197b7          	lui	a5,0x21019
22015bfe:	a887a303          	lw	t1,-1400(a5) # 21018a88 <HeapSize+0x21017a88>
22015c02:	8302                	jr	t1

22015c04 <Psram_SetDriveStrength>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_SetDriveStrength(SPI_Psram_Cfg_Type *psramCfg) {
    return RomDriver_Psram_SetDriveStrength(psramCfg);
22015c04:	210197b7          	lui	a5,0x21019
22015c08:	a8c7a303          	lw	t1,-1396(a5) # 21018a8c <HeapSize+0x21017a8c>
22015c0c:	8302                	jr	t1

22015c0e <Psram_SetBurstWrap>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_SetBurstWrap(SPI_Psram_Cfg_Type *psramCfg) {
    return RomDriver_Psram_SetBurstWrap(psramCfg);
22015c0e:	210197b7          	lui	a5,0x21019
22015c12:	a907a303          	lw	t1,-1392(a5) # 21018a90 <HeapSize+0x21017a90>
22015c16:	8302                	jr	t1

22015c18 <Psram_ReadId>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
void Psram_ReadId(SPI_Psram_Cfg_Type *psramCfg, uint8_t *data) {
    RomDriver_Psram_ReadId(psramCfg, data);
22015c18:	210197b7          	lui	a5,0x21019
22015c1c:	a947a303          	lw	t1,-1388(a5) # 21018a94 <HeapSize+0x21017a94>
22015c20:	8302                	jr	t1

22015c22 <Psram_EnterQuadMode>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_EnterQuadMode(SPI_Psram_Cfg_Type *psramCfg) {
    return RomDriver_Psram_EnterQuadMode(psramCfg);
22015c22:	210197b7          	lui	a5,0x21019
22015c26:	a987a303          	lw	t1,-1384(a5) # 21018a98 <HeapSize+0x21017a98>
22015c2a:	8302                	jr	t1

22015c2c <Psram_ExitQuadMode>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_ExitQuadMode(SPI_Psram_Cfg_Type *psramCfg) {
    return RomDriver_Psram_ExitQuadMode(psramCfg);
22015c2c:	210197b7          	lui	a5,0x21019
22015c30:	a9c7a303          	lw	t1,-1380(a5) # 21018a9c <HeapSize+0x21017a9c>
22015c34:	8302                	jr	t1

22015c36 <Psram_ToggleBurstLength>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_ToggleBurstLength(SPI_Psram_Cfg_Type *psramCfg, PSRAM_Ctrl_Mode ctrlMode) {
    return RomDriver_Psram_ToggleBurstLength(psramCfg, ctrlMode);
22015c36:	210197b7          	lui	a5,0x21019
22015c3a:	aa07a303          	lw	t1,-1376(a5) # 21018aa0 <HeapSize+0x21017aa0>
22015c3e:	8302                	jr	t1

22015c40 <Psram_SoftwareReset>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_SoftwareReset(SPI_Psram_Cfg_Type *psramCfg, PSRAM_Ctrl_Mode ctrlMode) {
    return RomDriver_Psram_SoftwareReset(psramCfg, ctrlMode);
22015c40:	210197b7          	lui	a5,0x21019
22015c44:	aa47a303          	lw	t1,-1372(a5) # 21018aa4 <HeapSize+0x21017aa4>
22015c48:	8302                	jr	t1

22015c4a <Psram_Set_IDbus_Cfg>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_Set_IDbus_Cfg(SPI_Psram_Cfg_Type *psramCfg,
    SF_Ctrl_IO_Type ioMode, uint32_t addr, uint32_t len) {
    return RomDriver_Psram_Set_IDbus_Cfg(psramCfg, ioMode, addr, len);
22015c4a:	210197b7          	lui	a5,0x21019
22015c4e:	aa87a303          	lw	t1,-1368(a5) # 21018aa8 <HeapSize+0x21017aa8>
22015c52:	8302                	jr	t1

22015c54 <Psram_Cache_Write_Set>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_Cache_Write_Set(SPI_Psram_Cfg_Type *psramCfg, SF_Ctrl_IO_Type ioMode,
    BL_Fun_Type wtEn, BL_Fun_Type wbEn, BL_Fun_Type waEn) {
    return RomDriver_Psram_Cache_Write_Set(psramCfg, ioMode, wtEn, wbEn, waEn);
22015c54:	210197b7          	lui	a5,0x21019
22015c58:	aac7a303          	lw	t1,-1364(a5) # 21018aac <HeapSize+0x21017aac>
22015c5c:	8302                	jr	t1

22015c5e <Psram_Write>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_Write(SPI_Psram_Cfg_Type *psramCfg,
    SF_Ctrl_IO_Type ioMode, uint32_t addr, uint8_t *data, uint32_t len) {
    return RomDriver_Psram_Write(psramCfg, ioMode, addr, data, len);
22015c5e:	210197b7          	lui	a5,0x21019
22015c62:	ab07a303          	lw	t1,-1360(a5) # 21018ab0 <HeapSize+0x21017ab0>
22015c66:	8302                	jr	t1

22015c68 <Psram_Read>:
}

__ALWAYS_INLINE ATTR_TCM_SECTION
BL_Err_Type Psram_Read(SPI_Psram_Cfg_Type *psramCfg,
    SF_Ctrl_IO_Type ioMode, uint32_t addr, uint8_t *data, uint32_t len) {
    return RomDriver_Psram_Read(psramCfg, ioMode, addr, data, len);
22015c68:	210197b7          	lui	a5,0x21019
22015c6c:	ab47a303          	lw	t1,-1356(a5) # 21018ab4 <HeapSize+0x21017ab4>
22015c70:	8302                	jr	t1

22015c72 <UART_GetRxFifoCount>:
    uint32_t UARTx = uartAddr[uartId];
22015c72:	230067b7          	lui	a5,0x23006
22015c76:	050a                	slli	a0,a0,0x2
22015c78:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
22015c7c:	97aa                	add	a5,a5,a0
    return BL_GET_REG_BITS_VAL(BL_RD_REG(UARTx,UART_FIFO_CONFIG_1),UART_RX_FIFO_CNT);
22015c7e:	439c                	lw	a5,0(a5)
22015c80:	0847a503          	lw	a0,132(a5)
22015c84:	8121                	srli	a0,a0,0x8
}
22015c86:	0ff57513          	andi	a0,a0,255
22015c8a:	8082                	ret

22015c8c <UART_ReceiveData>:
    uint32_t UARTx = uartAddr[uartId];
22015c8c:	230067b7          	lui	a5,0x23006
22015c90:	00251713          	slli	a4,a0,0x2
22015c94:	12c78793          	addi	a5,a5,300 # 2300612c <uartAddr>
{
22015c98:	1101                	addi	sp,sp,-32
    uint32_t UARTx = uartAddr[uartId];
22015c9a:	97ba                	add	a5,a5,a4
{
22015c9c:	c84a                	sw	s2,16(sp)
    uint32_t UARTx = uartAddr[uartId];
22015c9e:	0007a903          	lw	s2,0(a5)
{
22015ca2:	cc22                	sw	s0,24(sp)
22015ca4:	ca26                	sw	s1,20(sp)
22015ca6:	ce06                	sw	ra,28(sp)
22015ca8:	84aa                	mv	s1,a0
    while(rxLen<maxLen && UART_GetRxFifoCount(uartId)>0){
22015caa:	4401                	li	s0,0
22015cac:	c62e                	sw	a1,12(sp)
22015cae:	c432                	sw	a2,8(sp)
22015cb0:	00860763          	beq	a2,s0,22015cbe <UART_ReceiveData+0x32>
22015cb4:	8526                	mv	a0,s1
22015cb6:	3f75                	jal	22015c72 <UART_GetRxFifoCount>
22015cb8:	4622                	lw	a2,8(sp)
22015cba:	45b2                	lw	a1,12(sp)
22015cbc:	e901                	bnez	a0,22015ccc <UART_ReceiveData+0x40>
}
22015cbe:	8522                	mv	a0,s0
22015cc0:	40f2                	lw	ra,28(sp)
22015cc2:	4462                	lw	s0,24(sp)
22015cc4:	44d2                	lw	s1,20(sp)
22015cc6:	4942                	lw	s2,16(sp)
22015cc8:	6105                	addi	sp,sp,32
22015cca:	8082                	ret
        data[rxLen++] = BL_RD_BYTE(UARTx+UART_FIFO_RDATA_OFFSET);
22015ccc:	08c94703          	lbu	a4,140(s2)
22015cd0:	008587b3          	add	a5,a1,s0
22015cd4:	0405                	addi	s0,s0,1
22015cd6:	00e78023          	sb	a4,0(a5)
22015cda:	bfc9                	j	22015cac <UART_ReceiveData+0x20>

22015cdc <jtag_process>:

ATTR_CLOCK_SECTION void jtag_process(void)
{
22015cdc:	1141                	addi	sp,sp,-16
    uint32_t usb_tx_data = 0;
    uint32_t data = 0;
    register volatile uint32_t *pio __asm ("tp") = (volatile uint32_t *)0x40000180;
22015cde:	400007b7          	lui	a5,0x40000
{
22015ce2:	c422                	sw	s0,8(sp)
    register volatile uint32_t *pio __asm ("tp") = (volatile uint32_t *)0x40000180;
22015ce4:	18078213          	addi	tp,a5,384 # 40000180 <__ram_load_addr+0x1cff325c>
    register uint32_t bitbang = 0;

    if (!jtag_received_flag)
22015ce8:	00018793          	mv	a5,gp
22015cec:	4007a783          	lw	a5,1024(a5)
{
22015cf0:	c606                	sw	ra,12(sp)
    if (!jtag_received_flag)
22015cf2:	12078b63          	beqz	a5,22015e28 <jtag_process+0x14c>
22015cf6:	00018413          	mv	s0,gp
  __ASM__ volatile ("csrci mstatus, 8");
22015cfa:	30047073          	csrci	mstatus,8
        return;
    disable_irq();
    //if (jtag_received_flag)
    {
        switch (mpsse_status)
22015cfe:	44842783          	lw	a5,1096(s0)
22015d02:	472d                	li	a4,11
22015d04:	48f76a63          	bltu	a4,a5,22016198 <jtag_process+0x4bc>
22015d08:	23006737          	lui	a4,0x23006
22015d0c:	078a                	slli	a5,a5,0x2
22015d0e:	ad470713          	addi	a4,a4,-1324 # 23005ad4 <led_pins+0x80>
22015d12:	97ba                	add	a5,a5,a4
22015d14:	439c                	lw	a5,0(a5)
22015d16:	8782                	jr	a5
        {
            case MPSSE_IDLE:
                jtag_cmd = jtag_rx_buffer[jtag_rx_pos];
22015d18:	44442783          	lw	a5,1092(s0)
22015d1c:	03d00713          	li	a4,61
22015d20:	97a2                	add	a5,a5,s0
22015d22:	4047c783          	lbu	a5,1028(a5)
22015d26:	44f42623          	sw	a5,1100(s0)
                //MSG("cmd:0x%02x\r\n",jtag_cmd);

                switch (jtag_cmd)
22015d2a:	02e78c63          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d2e:	06f76263          	bltu	a4,a5,22015d92 <jtag_process+0xb6>
22015d32:	476d                	li	a4,27
22015d34:	00e78f63          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015d38:	02f76763          	bltu	a4,a5,22015d66 <jtag_process+0x8a>
22015d3c:	4755                	li	a4,21
22015d3e:	02e78263          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d42:	00f76a63          	bltu	a4,a5,22015d56 <jtag_process+0x7a>
22015d46:	4745                	li	a4,17
22015d48:	00e78d63          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d4c:	474d                	li	a4,19
22015d4e:	0ae79063          	bne	a5,a4,22015dee <jtag_process+0x112>
                    case 0x13:
                    case 0x17:
#if MPSSE_SPI_HW
                        spi_off();
#endif
                        mpsse_status = MPSSE_RCV_LENGTH;
22015d52:	4791                	li	a5,4
22015d54:	aa09                	j	22015e66 <jtag_process+0x18a>
22015d56:	475d                	li	a4,23
22015d58:	fee78de3          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015d5c:	4765                	li	a4,25
22015d5e:	08e79863          	bne	a5,a4,22015dee <jtag_process+0x112>
                        mpsse_status = MPSSE_RCV_LENGTH_L;
22015d62:	4785                	li	a5,1
22015d64:	a209                	j	22015e66 <jtag_process+0x18a>
22015d66:	03100713          	li	a4,49
22015d6a:	fee78ce3          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d6e:	00f76763          	bltu	a4,a5,22015d7c <jtag_process+0xa0>
22015d72:	4775                	li	a4,29
22015d74:	fee787e3          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d78:	477d                	li	a4,31
22015d7a:	bfd1                	j	22015d4e <jtag_process+0x72>
22015d7c:	03900713          	li	a4,57
22015d80:	fee781e3          	beq	a5,a4,22015d62 <jtag_process+0x86>
22015d84:	03b00713          	li	a4,59
22015d88:	fce785e3          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015d8c:	03500713          	li	a4,53
22015d90:	b7f9                	j	22015d5e <jtag_process+0x82>
22015d92:	08100713          	li	a4,129
22015d96:	0ae78b63          	beq	a5,a4,22015e4c <jtag_process+0x170>
22015d9a:	02f76a63          	bltu	a4,a5,22015dce <jtag_process+0xf2>
22015d9e:	04f00713          	li	a4,79
22015da2:	fae788e3          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015da6:	00f76963          	bltu	a4,a5,22015db8 <jtag_process+0xdc>
22015daa:	03f00713          	li	a4,63
22015dae:	fae782e3          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015db2:	04b00713          	li	a4,75
22015db6:	bf61                	j	22015d4e <jtag_process+0x72>
22015db8:	06f00713          	li	a4,111
22015dbc:	f8e78be3          	beq	a5,a4,22015d52 <jtag_process+0x76>
22015dc0:	08000713          	li	a4,128
22015dc4:	0ae78063          	beq	a5,a4,22015e64 <jtag_process+0x188>
22015dc8:	06b00713          	li	a4,107
22015dcc:	b749                	j	22015d4e <jtag_process+0x72>
22015dce:	08500713          	li	a4,133
22015dd2:	04f76f63          	bltu	a4,a5,22015e30 <jtag_process+0x154>
22015dd6:	08400713          	li	a4,132
22015dda:	06e7f363          	bgeu	a5,a4,22015e40 <jtag_process+0x164>
22015dde:	08200713          	li	a4,130
22015de2:	08e78163          	beq	a5,a4,22015e64 <jtag_process+0x188>
22015de6:	08300713          	li	a4,131
22015dea:	06e78163          	beq	a5,a4,22015e4c <jtag_process+0x170>
                        jtag_rx_pos++;
                        break;
                    default:
                        usb_tx_data = 0xFA;
                        jtag_write(usb_tx_data);
22015dee:	0fa00513          	li	a0,250
22015df2:	00feb097          	auipc	ra,0xfeb
22015df6:	202080e7          	jalr	514(ra) # 23000ff4 <jtag_write>
                        mpsse_status = MPSSE_ERROR;
22015dfa:	4799                	li	a5,6
                else if (jtag_cmd == 0x11 || jtag_cmd == 0x31)
#else
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31 || jtag_cmd == 0x15 || jtag_cmd == 0x35)
#endif
                {
                    mpsse_status = MPSSE_TRANSMIT_BYTE_MSB;
22015dfc:	44f42423          	sw	a5,1096(s0)
            default:
                mpsse_status = MPSSE_IDLE;
                break;
        }

        if (jtag_rx_pos >= jtag_rx_len)
22015e00:	420257b7          	lui	a5,0x42025
22015e04:	44442703          	lw	a4,1092(s0)
22015e08:	4387a783          	lw	a5,1080(a5) # 42025438 <jtag_rx_len>
22015e0c:	00f76c63          	bltu	a4,a5,22015e24 <jtag_process+0x148>
        {
            jtag_received_flag = false;
            usbd_ep_read(0x02, NULL, 0, NULL);
22015e10:	4681                	li	a3,0
22015e12:	4601                	li	a2,0
22015e14:	4581                	li	a1,0
22015e16:	4509                	li	a0,2
            jtag_received_flag = false;
22015e18:	40042023          	sw	zero,1024(s0)
            usbd_ep_read(0x02, NULL, 0, NULL);
22015e1c:	00feb097          	auipc	ra,0xfeb
22015e20:	eee080e7          	jalr	-274(ra) # 23000d0a <usbd_ep_read>
  __ASM__ volatile ("csrsi mstatus, 8");
22015e24:	30046073          	csrsi	mstatus,8

        }
    }
    enable_irq();
22015e28:	40b2                	lw	ra,12(sp)
22015e2a:	4422                	lw	s0,8(sp)
22015e2c:	0141                	addi	sp,sp,16
22015e2e:	8082                	ret
22015e30:	08600713          	li	a4,134
22015e34:	02e78863          	beq	a5,a4,22015e64 <jtag_process+0x188>
22015e38:	08700713          	li	a4,135
22015e3c:	fae799e3          	bne	a5,a4,22015dee <jtag_process+0x112>
                jtag_rx_pos++;
22015e40:	44442783          	lw	a5,1092(s0)
22015e44:	0785                	addi	a5,a5,1
22015e46:	44f42223          	sw	a5,1092(s0)
                break;
22015e4a:	bf5d                	j	22015e00 <jtag_process+0x124>
                        usb_tx_data = jtag_rx_buffer[jtag_rx_pos] - 0x80;
22015e4c:	44442783          	lw	a5,1092(s0)
22015e50:	97a2                	add	a5,a5,s0
                        jtag_write(usb_tx_data);
22015e52:	4047c503          	lbu	a0,1028(a5)
22015e56:	08054513          	xori	a0,a0,128
22015e5a:	00feb097          	auipc	ra,0xfeb
22015e5e:	19a080e7          	jalr	410(ra) # 23000ff4 <jtag_write>
                        jtag_rx_pos++;
22015e62:	bff9                	j	22015e40 <jtag_process+0x164>
                        mpsse_status = MPSSE_NO_OP_1;
22015e64:	47a5                	li	a5,9
                        mpsse_status = MPSSE_RCV_LENGTH_L;
22015e66:	44f42423          	sw	a5,1096(s0)
                        jtag_rx_pos++;
22015e6a:	bfd9                	j	22015e40 <jtag_process+0x164>
                mpsse_longlen = jtag_rx_buffer[jtag_rx_pos];
22015e6c:	44442783          	lw	a5,1092(s0)
22015e70:	97a2                	add	a5,a5,s0
22015e72:	4047c783          	lbu	a5,1028(a5)
22015e76:	44f42823          	sw	a5,1104(s0)
                mpsse_status = MPSSE_RCV_LENGTH_H;
22015e7a:	4789                	li	a5,2
22015e7c:	b7ed                	j	22015e66 <jtag_process+0x18a>
                mpsse_longlen |= (jtag_rx_buffer[jtag_rx_pos] << 8) & 0xff00;
22015e7e:	44442783          	lw	a5,1092(s0)
22015e82:	45042703          	lw	a4,1104(s0)
22015e86:	97a2                	add	a5,a5,s0
22015e88:	4047c783          	lbu	a5,1028(a5)
22015e8c:	07a2                	slli	a5,a5,0x8
22015e8e:	8fd9                	or	a5,a5,a4
22015e90:	44f42823          	sw	a5,1104(s0)
                jtag_rx_pos++;
22015e94:	44442783          	lw	a5,1092(s0)
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31 || jtag_cmd == 0x15 || jtag_cmd == 0x35)
22015e98:	4745                	li	a4,17
                jtag_rx_pos++;
22015e9a:	0785                	addi	a5,a5,1
22015e9c:	44f42223          	sw	a5,1092(s0)
                if (jtag_cmd == 0x11 || jtag_cmd == 0x31 || jtag_cmd == 0x15 || jtag_cmd == 0x35)
22015ea0:	44c42783          	lw	a5,1100(s0)
22015ea4:	fdb7f793          	andi	a5,a5,-37
22015ea8:	00e79463          	bne	a5,a4,22015eb0 <jtag_process+0x1d4>
                    mpsse_status = MPSSE_TRANSMIT_BYTE_MSB;
22015eac:	47ad                	li	a5,11
22015eae:	b7b9                	j	22015dfc <jtag_process+0x120>
                    mpsse_status = MPSSE_TRANSMIT_BYTE;
22015eb0:	478d                	li	a5,3
22015eb2:	b7a9                	j	22015dfc <jtag_process+0x120>
                __asm volatile ("nop":::"memory");
22015eb4:	0001                	nop
                data = jtag_rx_buffer[jtag_rx_pos];
22015eb6:	44442783          	lw	a5,1092(s0)
                    pio[2] &= ~(1 << TCK_PIN);
22015eba:	7661                	lui	a2,0xffff8
22015ebc:	4721                	li	a4,8
                data = jtag_rx_buffer[jtag_rx_pos];
22015ebe:	97a2                	add	a5,a5,s0
22015ec0:	4047c683          	lbu	a3,1028(a5)
                usb_tx_data = 0;
22015ec4:	4501                	li	a0,0
                    pio[2] &= ~(1 << TCK_PIN);
22015ec6:	8792                	mv	a5,tp
22015ec8:	167d                	addi	a2,a2,-1
                    pio[2] |= (1 << TCK_PIN);
22015eca:	6821                	lui	a6,0x8
                    pio[2] &= ~(1 << TCK_PIN);
22015ecc:	478c                	lw	a1,8(a5)
22015ece:	8df1                	and	a1,a1,a2
22015ed0:	c78c                	sw	a1,8(a5)
                    if (data & 0x01) {
22015ed2:	0016f593          	andi	a1,a3,1
22015ed6:	c1bd                	beqz	a1,22015f3c <jtag_process+0x260>
                        pio[2] |= (1 << TDI_PIN);
22015ed8:	478c                	lw	a1,8(a5)
22015eda:	0015e593          	ori	a1,a1,1
                        pio[2] &= ~(1 << TDI_PIN);
22015ede:	c78c                	sw	a1,8(a5)
                    pio[2] |= (1 << TCK_PIN);
22015ee0:	478c                	lw	a1,8(a5)
                    data >>= 1;
22015ee2:	8285                	srli	a3,a3,0x1
                    usb_tx_data >>= 1;
22015ee4:	8105                	srli	a0,a0,0x1
                    pio[2] |= (1 << TCK_PIN);
22015ee6:	0105e5b3          	or	a1,a1,a6
22015eea:	c78c                	sw	a1,8(a5)
                    if (pio[0] & (1 << TDO_PIN))
22015eec:	438c                	lw	a1,0(a5)
22015eee:	8989                	andi	a1,a1,2
22015ef0:	c199                	beqz	a1,22015ef6 <jtag_process+0x21a>
                        usb_tx_data |= 0x80;
22015ef2:	08056513          	ori	a0,a0,128
                for (uint32_t i = 8; i ; i--)
22015ef6:	177d                	addi	a4,a4,-1
22015ef8:	fb71                	bnez	a4,22015ecc <jtag_process+0x1f0>
                pio[2] &= ~(1<<TCK_PIN);
22015efa:	4798                	lw	a4,8(a5)
22015efc:	76e1                	lui	a3,0xffff8
22015efe:	16fd                	addi	a3,a3,-1
22015f00:	8f75                	and	a4,a4,a3
22015f02:	c798                	sw	a4,8(a5)
                if (jtag_cmd == 0x39 || jtag_cmd == 0x3d)
22015f04:	44c42783          	lw	a5,1100(s0)
22015f08:	03900713          	li	a4,57
22015f0c:	9bed                	andi	a5,a5,-5
22015f0e:	00e79863          	bne	a5,a4,22015f1e <jtag_process+0x242>
                    jtag_write(usb_tx_data);
22015f12:	0ff57513          	andi	a0,a0,255
22015f16:	00feb097          	auipc	ra,0xfeb
22015f1a:	0de080e7          	jalr	222(ra) # 23000ff4 <jtag_write>
                if (mpsse_longlen == 0)
22015f1e:	45042783          	lw	a5,1104(s0)
22015f22:	e399                	bnez	a5,22015f28 <jtag_process+0x24c>
                    mpsse_status = MPSSE_IDLE;
22015f24:	44042423          	sw	zero,1096(s0)
                mpsse_longlen--;
22015f28:	17fd                	addi	a5,a5,-1
22015f2a:	44f42823          	sw	a5,1104(s0)
                jtag_rx_pos++;
22015f2e:	44442783          	lw	a5,1092(s0)
22015f32:	0785                	addi	a5,a5,1
22015f34:	44f42223          	sw	a5,1092(s0)
                __asm volatile ("nop":::"memory");
22015f38:	0001                	nop
                break;
22015f3a:	b5d9                	j	22015e00 <jtag_process+0x124>
                        pio[2] &= ~(1 << TDI_PIN);
22015f3c:	478c                	lw	a1,8(a5)
22015f3e:	99f9                	andi	a1,a1,-2
22015f40:	bf79                	j	22015ede <jtag_process+0x202>
                data = jtag_rx_buffer[jtag_rx_pos];
22015f42:	44442783          	lw	a5,1092(s0)
                    SCK_LOW;
22015f46:	7661                	lui	a2,0xffff8
                bitbang = pio[2];
22015f48:	4721                	li	a4,8
                data = jtag_rx_buffer[jtag_rx_pos];
22015f4a:	97a2                	add	a5,a5,s0
22015f4c:	4047c683          	lbu	a3,1028(a5)
                bitbang = pio[2];
22015f50:	00822783          	lw	a5,8(tp) # 8 <__metal_chicken_bit+0x8>
                usb_tx_data = 0;
22015f54:	4501                	li	a0,0
                    SCK_LOW;
22015f56:	167d                	addi	a2,a2,-1
22015f58:	400007b7          	lui	a5,0x40000
                    SCK_HIGH;
22015f5c:	6821                	lui	a6,0x8
                    SCK_LOW;
22015f5e:	1887a583          	lw	a1,392(a5) # 40000188 <__ram_load_addr+0x1cff3264>
22015f62:	8df1                	and	a1,a1,a2
22015f64:	18b7a423          	sw	a1,392(a5)
                    if (data & 0x80) {
22015f68:	0806f593          	andi	a1,a3,128
22015f6c:	c9bd                	beqz	a1,22015fe2 <jtag_process+0x306>
                        MOSI_HIGH;
22015f6e:	1887a583          	lw	a1,392(a5)
22015f72:	0015e593          	ori	a1,a1,1
                        MOSI_LOW;
22015f76:	18b7a423          	sw	a1,392(a5)
                    SCK_HIGH;
22015f7a:	1887a583          	lw	a1,392(a5)
                    data <<= 1;
22015f7e:	0686                	slli	a3,a3,0x1
                    usb_tx_data <<= 1;
22015f80:	0506                	slli	a0,a0,0x1
                    SCK_HIGH;
22015f82:	0105e5b3          	or	a1,a1,a6
22015f86:	18b7a423          	sw	a1,392(a5)
                    if (MISO)
22015f8a:	1807a583          	lw	a1,384(a5)
22015f8e:	8989                	andi	a1,a1,2
22015f90:	c199                	beqz	a1,22015f96 <jtag_process+0x2ba>
                        usb_tx_data |= 0x01;
22015f92:	00156513          	ori	a0,a0,1
                for (uint32_t i = 8; i ; i--)
22015f96:	177d                	addi	a4,a4,-1
22015f98:	f379                	bnez	a4,22015f5e <jtag_process+0x282>
                SCK_LOW;
22015f9a:	400006b7          	lui	a3,0x40000
22015f9e:	1886a783          	lw	a5,392(a3) # 40000188 <__ram_load_addr+0x1cff3264>
22015fa2:	7761                	lui	a4,0xffff8
22015fa4:	177d                	addi	a4,a4,-1
22015fa6:	8ff9                	and	a5,a5,a4
22015fa8:	18f6a423          	sw	a5,392(a3)
                if (jtag_cmd == 0x31 || jtag_cmd == 0x35)
22015fac:	44c42783          	lw	a5,1100(s0)
22015fb0:	03100713          	li	a4,49
22015fb4:	9bed                	andi	a5,a5,-5
22015fb6:	00e79863          	bne	a5,a4,22015fc6 <jtag_process+0x2ea>
                    jtag_write(usb_tx_data);
22015fba:	0ff57513          	andi	a0,a0,255
22015fbe:	00feb097          	auipc	ra,0xfeb
22015fc2:	036080e7          	jalr	54(ra) # 23000ff4 <jtag_write>
                if (mpsse_longlen == 0)
22015fc6:	45042783          	lw	a5,1104(s0)
22015fca:	e399                	bnez	a5,22015fd0 <jtag_process+0x2f4>
                    mpsse_status = MPSSE_IDLE;
22015fcc:	44042423          	sw	zero,1096(s0)
                jtag_rx_pos++;
22015fd0:	44442703          	lw	a4,1092(s0)
                mpsse_longlen--;
22015fd4:	17fd                	addi	a5,a5,-1
22015fd6:	44f42823          	sw	a5,1104(s0)
                jtag_rx_pos++;
22015fda:	0705                	addi	a4,a4,1
22015fdc:	44e42223          	sw	a4,1092(s0)
                break;
22015fe0:	b505                	j	22015e00 <jtag_process+0x124>
                        MOSI_LOW;
22015fe2:	1887a583          	lw	a1,392(a5)
22015fe6:	99f9                	andi	a1,a1,-2
22015fe8:	b779                	j	22015f76 <jtag_process+0x29a>
                mpsse_shortlen = jtag_rx_buffer[jtag_rx_pos];
22015fea:	44442783          	lw	a5,1092(s0)
                if (jtag_cmd == 0x6b || jtag_cmd == 0x4b || jtag_cmd == 0x6f || jtag_cmd == 0x4f)
22015fee:	04b00693          	li	a3,75
                mpsse_shortlen = jtag_rx_buffer[jtag_rx_pos];
22015ff2:	97a2                	add	a5,a5,s0
22015ff4:	4047c783          	lbu	a5,1028(a5)
22015ff8:	44f42a23          	sw	a5,1108(s0)
                if (jtag_cmd == 0x6b || jtag_cmd == 0x4b || jtag_cmd == 0x6f || jtag_cmd == 0x4f)
22015ffc:	44c42783          	lw	a5,1100(s0)
22016000:	ffb7f713          	andi	a4,a5,-5
22016004:	fdb7f793          	andi	a5,a5,-37
22016008:	00d79463          	bne	a5,a3,22016010 <jtag_process+0x334>
                    mpsse_status = MPSSE_TMS_OUT;
2201600c:	47a1                	li	a5,8
2201600e:	bda1                	j	22015e66 <jtag_process+0x18a>
                else if (jtag_cmd == 0x13 || jtag_cmd == 0x17)
22016010:	47cd                	li	a5,19
22016012:	00f71463          	bne	a4,a5,2201601a <jtag_process+0x33e>
                    mpsse_status = MPSSE_TRANSMIT_BIT_MSB;
22016016:	479d                	li	a5,7
22016018:	b5b9                	j	22015e66 <jtag_process+0x18a>
                    mpsse_status = MPSSE_TRANSMIT_BIT;
2201601a:	4795                	li	a5,5
2201601c:	b5a9                	j	22015e66 <jtag_process+0x18a>
                data = jtag_rx_buffer[jtag_rx_pos];
2201601e:	44442783          	lw	a5,1092(s0)
22016022:	45442703          	lw	a4,1108(s0)
                bitbang = pio[2];
22016026:	00822683          	lw	a3,8(tp) # 8 <__metal_chicken_bit+0x8>
                data = jtag_rx_buffer[jtag_rx_pos];
2201602a:	97a2                	add	a5,a5,s0
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
2201602c:	75e1                	lui	a1,0xffff8
                        bitbang |= (1<<TCK_PIN);
2201602e:	6321                	lui	t1,0x8
                data = jtag_rx_buffer[jtag_rx_pos];
22016030:	4047c603          	lbu	a2,1028(a5)
                usb_tx_data = 0;
22016034:	4501                	li	a0,0
                bitbang = pio[2];
22016036:	8792                	mv	a5,tp
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
22016038:	15f9                	addi	a1,a1,-2
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
2201603a:	00130e93          	addi	t4,t1,1 # 8001 <HeapSize+0x7001>
                while ((mpsse_shortlen--) > 0);
2201603e:	5e7d                	li	t3,-1
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
22016040:	00b6f833          	and	a6,a3,a1
                    pio[2] = bitbang;
22016044:	0107a423          	sw	a6,8(a5)
                    if (data & 0x01) {
22016048:	00167893          	andi	a7,a2,1
                        bitbang |= (1<<TCK_PIN);
2201604c:	006866b3          	or	a3,a6,t1
                    if (data & 0x01) {
22016050:	00088463          	beqz	a7,22016058 <jtag_process+0x37c>
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
22016054:	01d866b3          	or	a3,a6,t4
                    pio[2] = bitbang;
22016058:	c794                	sw	a3,8(a5)
                    if (pio[0] & (1 << TDO_PIN))
2201605a:	0007a803          	lw	a6,0(a5)
                    data >>= 1;
2201605e:	8205                	srli	a2,a2,0x1
                    usb_tx_data >>= 1;
22016060:	8105                	srli	a0,a0,0x1
                    if (pio[0] & (1 << TDO_PIN))
22016062:	00287813          	andi	a6,a6,2
22016066:	00080463          	beqz	a6,2201606e <jtag_process+0x392>
                        usb_tx_data |= 0x80;
2201606a:	08056513          	ori	a0,a0,128
                while ((mpsse_shortlen--) > 0);
2201606e:	177d                	addi	a4,a4,-1
22016070:	fdc718e3          	bne	a4,t3,22016040 <jtag_process+0x364>
22016074:	44e42a23          	sw	a4,1108(s0)
                pio[2] &= ~(1<<TCK_PIN);
22016078:	4798                	lw	a4,8(a5)
2201607a:	76e1                	lui	a3,0xffff8
2201607c:	16fd                	addi	a3,a3,-1
2201607e:	8f75                	and	a4,a4,a3
22016080:	c798                	sw	a4,8(a5)
                if (jtag_cmd == 0x3b || jtag_cmd == 0x3f)
22016082:	44c42783          	lw	a5,1100(s0)
22016086:	03b00713          	li	a4,59
2201608a:	9bed                	andi	a5,a5,-5
                if (jtag_cmd == 0x6b || jtag_cmd == 0x6f)
2201608c:	04e79c63          	bne	a5,a4,220160e4 <jtag_process+0x408>
                    jtag_write(usb_tx_data);
22016090:	0ff57513          	andi	a0,a0,255
22016094:	a085                	j	220160f4 <jtag_process+0x418>
                data = jtag_rx_buffer[jtag_rx_pos];
22016096:	44442783          	lw	a5,1092(s0)
2201609a:	45442703          	lw	a4,1108(s0)
                bitbang = pio[2];
2201609e:	00822683          	lw	a3,8(tp) # 8 <__metal_chicken_bit+0x8>
                data = jtag_rx_buffer[jtag_rx_pos];
220160a2:	97a2                	add	a5,a5,s0
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
220160a4:	75e1                	lui	a1,0xffff8
                        bitbang |= (1<<TCK_PIN);
220160a6:	68a1                	lui	a7,0x8
                data = jtag_rx_buffer[jtag_rx_pos];
220160a8:	4047c603          	lbu	a2,1028(a5)
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
220160ac:	15f9                	addi	a1,a1,-2
                bitbang = pio[2];
220160ae:	8792                	mv	a5,tp
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
220160b0:	00188e13          	addi	t3,a7,1 # 8001 <HeapSize+0x7001>
                while ((mpsse_shortlen--) > 0);
220160b4:	537d                	li	t1,-1
                    bitbang &= ~((1 << TCK_PIN) | (1 << TDI_PIN));
220160b6:	00b6f533          	and	a0,a3,a1
                    pio[2] = bitbang;
220160ba:	c788                	sw	a0,8(a5)
                    if (data & 0x80) {
220160bc:	08067813          	andi	a6,a2,128
                        bitbang |= (1<<TCK_PIN);
220160c0:	011566b3          	or	a3,a0,a7
                    if (data & 0x80) {
220160c4:	00080463          	beqz	a6,220160cc <jtag_process+0x3f0>
                        bitbang |= ((1 << TCK_PIN) | (1 << TDI_PIN));
220160c8:	01c566b3          	or	a3,a0,t3
                    pio[2] = bitbang;   
220160cc:	c794                	sw	a3,8(a5)
                while ((mpsse_shortlen--) > 0);
220160ce:	177d                	addi	a4,a4,-1
                    data <<= 1;
220160d0:	0606                	slli	a2,a2,0x1
                while ((mpsse_shortlen--) > 0);
220160d2:	fe6712e3          	bne	a4,t1,220160b6 <jtag_process+0x3da>
220160d6:	44e42a23          	sw	a4,1108(s0)
                pio[2] &= ~(1<<TCK_PIN);
220160da:	4798                	lw	a4,8(a5)
220160dc:	76e1                	lui	a3,0xffff8
220160de:	16fd                	addi	a3,a3,-1
220160e0:	8f75                	and	a4,a4,a3
220160e2:	c798                	sw	a4,8(a5)
                mpsse_status = MPSSE_IDLE;
220160e4:	44042423          	sw	zero,1096(s0)
220160e8:	bba1                	j	22015e40 <jtag_process+0x164>
                usb_tx_data = jtag_rx_buffer[jtag_rx_pos];
220160ea:	44442783          	lw	a5,1092(s0)
220160ee:	97a2                	add	a5,a5,s0
                jtag_write(usb_tx_data);
220160f0:	4047c503          	lbu	a0,1028(a5)
                    jtag_write(usb_tx_data);
220160f4:	00feb097          	auipc	ra,0xfeb
220160f8:	f00080e7          	jalr	-256(ra) # 23000ff4 <jtag_write>
                mpsse_status = MPSSE_IDLE;
220160fc:	b7e5                	j	220160e4 <jtag_process+0x408>
                data = jtag_rx_buffer[jtag_rx_pos];
220160fe:	44442783          	lw	a5,1092(s0)
22016102:	97a2                	add	a5,a5,s0
22016104:	4047c683          	lbu	a3,1028(a5)
                if (data & 0x80)
22016108:	8792                	mv	a5,tp
2201610a:	01869713          	slli	a4,a3,0x18
2201610e:	8761                	srai	a4,a4,0x18
22016110:	06075963          	bgez	a4,22016182 <jtag_process+0x4a6>
                    pio[2] |= 1 << TDI_PIN;
22016114:	00822703          	lw	a4,8(tp) # 8 <__metal_chicken_bit+0x8>
22016118:	00176713          	ori	a4,a4,1
                    pio[2] &= ~(1 << TDI_PIN);
2201611c:	00e22423          	sw	a4,8(tp) # 8 <__metal_chicken_bit+0x8>
                bitbang = pio[2];
22016120:	4790                	lw	a2,8(a5)
22016122:	45442703          	lw	a4,1108(s0)
                    bitbang &= ~((1 << TCK_PIN) | (1 << TMS_PIN));
22016126:	75e1                	lui	a1,0xffff8
                        bitbang |= (1<<TCK_PIN);
22016128:	6321                	lui	t1,0x8
                usb_tx_data = 0;
2201612a:	4501                	li	a0,0
                    bitbang &= ~((1 << TCK_PIN) | (1 << TMS_PIN));
2201612c:	15ed                	addi	a1,a1,-5
                        bitbang |= ((1 << TCK_PIN) | (1 << TMS_PIN));
2201612e:	00430e93          	addi	t4,t1,4 # 8004 <HeapSize+0x7004>
                while ((mpsse_shortlen--) > 0);
22016132:	5e7d                	li	t3,-1
                    bitbang &= ~((1 << TCK_PIN) | (1 << TMS_PIN));
22016134:	00b67833          	and	a6,a2,a1
                    pio[2] = bitbang;
22016138:	0107a423          	sw	a6,8(a5)
                    if (data & 0x01) {
2201613c:	0016f893          	andi	a7,a3,1
                        bitbang |= (1<<TCK_PIN);
22016140:	00686633          	or	a2,a6,t1
                    if (data & 0x01) {
22016144:	00088463          	beqz	a7,2201614c <jtag_process+0x470>
                        bitbang |= ((1 << TCK_PIN) | (1 << TMS_PIN));
22016148:	01d86633          	or	a2,a6,t4
                    pio[2] = bitbang;
2201614c:	c790                	sw	a2,8(a5)
                    if (pio[0] & (1 << TDO_PIN))
2201614e:	0007a803          	lw	a6,0(a5)
                    data >>= 1;
22016152:	8285                	srli	a3,a3,0x1
                    usb_tx_data >>= 1;
22016154:	8105                	srli	a0,a0,0x1
                    if (pio[0] & (1 << TDO_PIN))
22016156:	00287813          	andi	a6,a6,2
2201615a:	00080463          	beqz	a6,22016162 <jtag_process+0x486>
                        usb_tx_data |= 0x80;
2201615e:	08056513          	ori	a0,a0,128
                while ((mpsse_shortlen--) > 0);
22016162:	177d                	addi	a4,a4,-1
22016164:	fdc718e3          	bne	a4,t3,22016134 <jtag_process+0x458>
22016168:	44e42a23          	sw	a4,1108(s0)
                pio[2] &= ~(1<<TCK_PIN);
2201616c:	4798                	lw	a4,8(a5)
2201616e:	76e1                	lui	a3,0xffff8
22016170:	16fd                	addi	a3,a3,-1
22016172:	8f75                	and	a4,a4,a3
22016174:	c798                	sw	a4,8(a5)
                if (jtag_cmd == 0x6b || jtag_cmd == 0x6f)
22016176:	44c42783          	lw	a5,1100(s0)
2201617a:	06b00713          	li	a4,107
2201617e:	9bed                	andi	a5,a5,-5
22016180:	b731                	j	2201608c <jtag_process+0x3b0>
                    pio[2] &= ~(1 << TDI_PIN);
22016182:	00822703          	lw	a4,8(tp) # 8 <__metal_chicken_bit+0x8>
22016186:	9b79                	andi	a4,a4,-2
22016188:	bf51                	j	2201611c <jtag_process+0x440>
                jtag_rx_pos++;
2201618a:	44442783          	lw	a5,1092(s0)
2201618e:	0785                	addi	a5,a5,1
22016190:	44f42223          	sw	a5,1092(s0)
                mpsse_status = MPSSE_NO_OP_2;
22016194:	47a9                	li	a5,10
22016196:	b19d                	j	22015dfc <jtag_process+0x120>
                mpsse_status = MPSSE_IDLE;
22016198:	44042423          	sw	zero,1096(s0)
                break;
2201619c:	b195                	j	22015e00 <jtag_process+0x124>

2201619e <AON_Power_On_MBG>:
    return RomDriver_AON_Power_On_MBG();
2201619e:	210197b7          	lui	a5,0x21019
220161a2:	8107a303          	lw	t1,-2032(a5) # 21018810 <HeapSize+0x21017810>
220161a6:	8302                	jr	t1

220161a8 <AON_Power_Off_MBG>:
    return RomDriver_AON_Power_Off_MBG();
220161a8:	210197b7          	lui	a5,0x21019
220161ac:	8147a303          	lw	t1,-2028(a5) # 21018814 <HeapSize+0x21017814>
220161b0:	8302                	jr	t1

220161b2 <AON_Power_On_XTAL>:
    return RomDriver_AON_Power_On_XTAL();
220161b2:	210197b7          	lui	a5,0x21019
220161b6:	8187a303          	lw	t1,-2024(a5) # 21018818 <HeapSize+0x21017818>
220161ba:	8302                	jr	t1

220161bc <AON_Set_Xtal_CapCode>:
    return RomDriver_AON_Set_Xtal_CapCode(capIn, capOut);
220161bc:	210197b7          	lui	a5,0x21019
220161c0:	81c7a303          	lw	t1,-2020(a5) # 2101881c <HeapSize+0x2101781c>
220161c4:	8302                	jr	t1

220161c6 <AON_Power_Off_XTAL>:
    return RomDriver_AON_Power_Off_XTAL();
220161c6:	210197b7          	lui	a5,0x21019
220161ca:	8207a303          	lw	t1,-2016(a5) # 21018820 <HeapSize+0x21017820>
220161ce:	8302                	jr	t1

220161d0 <GLB_Get_Root_CLK_Sel>:
    return RomDriver_GLB_Get_Root_CLK_Sel();
220161d0:	210197b7          	lui	a5,0x21019
220161d4:	8507a303          	lw	t1,-1968(a5) # 21018850 <HeapSize+0x21017850>
220161d8:	8302                	jr	t1

220161da <GLB_Set_System_CLK_Div>:
    return RomDriver_GLB_Set_System_CLK_Div(hclkDiv, bclkDiv);
220161da:	210197b7          	lui	a5,0x21019
220161de:	8547a303          	lw	t1,-1964(a5) # 21018854 <HeapSize+0x21017854>
220161e2:	8302                	jr	t1

220161e4 <GLB_Get_BCLK_Div>:
    return RomDriver_GLB_Get_BCLK_Div();
220161e4:	210197b7          	lui	a5,0x21019
220161e8:	8587a303          	lw	t1,-1960(a5) # 21018858 <HeapSize+0x21017858>
220161ec:	8302                	jr	t1

220161ee <GLB_Get_HCLK_Div>:
    return RomDriver_GLB_Get_HCLK_Div();
220161ee:	210197b7          	lui	a5,0x21019
220161f2:	85c7a303          	lw	t1,-1956(a5) # 2101885c <HeapSize+0x2101785c>
220161f6:	8302                	jr	t1

220161f8 <Update_SystemCoreClockWith_XTAL>:
    return RomDriver_Update_SystemCoreClockWith_XTAL(xtalType);
220161f8:	210197b7          	lui	a5,0x21019
220161fc:	8607a303          	lw	t1,-1952(a5) # 21018860 <HeapSize+0x21017860>
22016200:	8302                	jr	t1

22016202 <GLB_Set_System_CLK>:
    return RomDriver_GLB_Set_System_CLK(xtalType, clkFreq);
22016202:	210197b7          	lui	a5,0x21019
22016206:	8647a303          	lw	t1,-1948(a5) # 21018864 <HeapSize+0x21017864>
2201620a:	8302                	jr	t1

2201620c <System_Core_Clock_Update_From_RC32M>:
    return RomDriver_System_Core_Clock_Update_From_RC32M();
2201620c:	210197b7          	lui	a5,0x21019
22016210:	8687a303          	lw	t1,-1944(a5) # 21018868 <HeapSize+0x21017868>
22016214:	8302                	jr	t1

22016216 <GLB_Set_SF_CLK>:
    return RomDriver_GLB_Set_SF_CLK(enable, clkSel, div);
22016216:	210197b7          	lui	a5,0x21019
2201621a:	86c7a303          	lw	t1,-1940(a5) # 2101886c <HeapSize+0x2101786c>
2201621e:	8302                	jr	t1

22016220 <GLB_Power_Off_DLL>:
    return RomDriver_GLB_Power_Off_DLL();
22016220:	210197b7          	lui	a5,0x21019
22016224:	8707a303          	lw	t1,-1936(a5) # 21018870 <HeapSize+0x21017870>
22016228:	8302                	jr	t1

2201622a <GLB_Power_On_DLL>:
    return RomDriver_GLB_Power_On_DLL(xtalType);
2201622a:	210197b7          	lui	a5,0x21019
2201622e:	8747a303          	lw	t1,-1932(a5) # 21018874 <HeapSize+0x21017874>
22016232:	8302                	jr	t1

22016234 <GLB_Enable_DLL_All_Clks>:
    return RomDriver_GLB_Enable_DLL_All_Clks();
22016234:	210197b7          	lui	a5,0x21019
22016238:	8787a303          	lw	t1,-1928(a5) # 21018878 <HeapSize+0x21017878>
2201623c:	8302                	jr	t1

2201623e <GLB_Enable_DLL_Clk>:
    return RomDriver_GLB_Enable_DLL_Clk(dllClk);
2201623e:	210197b7          	lui	a5,0x21019
22016242:	87c7a303          	lw	t1,-1924(a5) # 2101887c <HeapSize+0x2101787c>
22016246:	8302                	jr	t1

22016248 <GLB_Disable_DLL_All_Clks>:
    return RomDriver_GLB_Disable_DLL_All_Clks();
22016248:	210197b7          	lui	a5,0x21019
2201624c:	8807a303          	lw	t1,-1920(a5) # 21018880 <HeapSize+0x21017880>
22016250:	8302                	jr	t1

22016252 <GLB_Disable_DLL_Clk>:
    return RomDriver_GLB_Disable_DLL_Clk(dllClk);
22016252:	210197b7          	lui	a5,0x21019
22016256:	8847a303          	lw	t1,-1916(a5) # 21018884 <HeapSize+0x21017884>
2201625a:	8302                	jr	t1

2201625c <EF_Ctrl_Get_Trim_Parity>:
    return RomDriver_EF_Ctrl_Get_Trim_Parity(val, len);
2201625c:	210197b7          	lui	a5,0x21019
22016260:	8d47a303          	lw	t1,-1836(a5) # 210188d4 <HeapSize+0x210178d4>
22016264:	8302                	jr	t1

22016266 <EF_Ctrl_Read_RC32K_Trim>:
    RomDriver_EF_Ctrl_Read_RC32K_Trim(trim);
22016266:	210197b7          	lui	a5,0x21019
2201626a:	8d87a303          	lw	t1,-1832(a5) # 210188d8 <HeapSize+0x210178d8>
2201626e:	8302                	jr	t1

22016270 <EF_Ctrl_Read_RC32M_Trim>:
    RomDriver_EF_Ctrl_Read_RC32M_Trim(trim);
22016270:	210197b7          	lui	a5,0x21019
22016274:	8dc7a303          	lw	t1,-1828(a5) # 210188dc <HeapSize+0x210178dc>
22016278:	8302                	jr	t1

2201627a <PDS_Trim_RC32M>:
    return RomDriver_PDS_Trim_RC32M();
2201627a:	210197b7          	lui	a5,0x21019
2201627e:	8e07a303          	lw	t1,-1824(a5) # 210188e0 <HeapSize+0x210178e0>
22016282:	8302                	jr	t1

22016284 <PDS_Select_RC32M_As_PLL_Ref>:
    return RomDriver_PDS_Select_RC32M_As_PLL_Ref();
22016284:	210197b7          	lui	a5,0x21019
22016288:	8e47a303          	lw	t1,-1820(a5) # 210188e4 <HeapSize+0x210178e4>
2201628c:	8302                	jr	t1

2201628e <PDS_Select_XTAL_As_PLL_Ref>:
    return RomDriver_PDS_Select_XTAL_As_PLL_Ref();
2201628e:	210197b7          	lui	a5,0x21019
22016292:	8e87a303          	lw	t1,-1816(a5) # 210188e8 <HeapSize+0x210178e8>
22016296:	8302                	jr	t1

22016298 <PDS_Power_On_PLL>:
    return RomDriver_PDS_Power_On_PLL(xtalType);
22016298:	210197b7          	lui	a5,0x21019
2201629c:	8ec7a303          	lw	t1,-1812(a5) # 210188ec <HeapSize+0x210178ec>
220162a0:	8302                	jr	t1

220162a2 <PDS_Enable_PLL_All_Clks>:
    return RomDriver_PDS_Enable_PLL_All_Clks();
220162a2:	210197b7          	lui	a5,0x21019
220162a6:	8f07a303          	lw	t1,-1808(a5) # 210188f0 <HeapSize+0x210178f0>
220162aa:	8302                	jr	t1

220162ac <PDS_Disable_PLL_All_Clks>:
    return RomDriver_PDS_Disable_PLL_All_Clks();
220162ac:	210197b7          	lui	a5,0x21019
220162b0:	8f47a303          	lw	t1,-1804(a5) # 210188f4 <HeapSize+0x210178f4>
220162b4:	8302                	jr	t1

220162b6 <PDS_Enable_PLL_Clk>:
    return RomDriver_PDS_Enable_PLL_Clk(pllClk);
220162b6:	210197b7          	lui	a5,0x21019
220162ba:	8f87a303          	lw	t1,-1800(a5) # 210188f8 <HeapSize+0x210178f8>
220162be:	8302                	jr	t1

220162c0 <PDS_Disable_PLL_Clk>:
    return RomDriver_PDS_Disable_PLL_Clk(pllClk);
220162c0:	210197b7          	lui	a5,0x21019
220162c4:	8fc7a303          	lw	t1,-1796(a5) # 210188fc <HeapSize+0x210178fc>
220162c8:	8302                	jr	t1

220162ca <PDS_Power_Off_PLL>:
    return RomDriver_PDS_Power_Off_PLL();
220162ca:	210197b7          	lui	a5,0x21019
220162ce:	9007a303          	lw	t1,-1792(a5) # 21018900 <HeapSize+0x21017900>
220162d2:	8302                	jr	t1

220162d4 <HBN_Trim_RC32K>:
    return RomDriver_HBN_Trim_RC32K();
220162d4:	210197b7          	lui	a5,0x21019
220162d8:	9287a303          	lw	t1,-1752(a5) # 21018928 <HeapSize+0x21017928>
220162dc:	8302                	jr	t1

220162de <HBN_Set_ROOT_CLK_Sel>:
    return RomDriver_HBN_Set_ROOT_CLK_Sel(rootClk);
220162de:	210197b7          	lui	a5,0x21019
220162e2:	92c7a303          	lw	t1,-1748(a5) # 2101892c <HeapSize+0x2101792c>
220162e6:	8302                	jr	t1
