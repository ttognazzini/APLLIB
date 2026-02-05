**Free
// define workstation attributes

// RI=Reverse Image, HI=Hi Intensity, BL=blink, UL=Underline, ND=N

// Non Protect fields
Dcl-C @NORMAL      const(x'20');
Dcl-C @RI          const(x'21');
Dcl-C @WHT         const(x'22');
Dcl-C @WHTRI       const(x'23');
Dcl-C @UL          const(x'24');
Dcl-C @ULRI        const(x'25');
Dcl-C @WHTUL       const(x'26');
Dcl-C @ND          const(x'27');
Dcl-C @RED         const(x'28');
Dcl-C @REDRI       const(x'29');
Dcl-C @REDBL       const(x'2A');
Dcl-C @REDRIBL     const(x'2B');
Dcl-C @REDUL       const(x'2C');
Dcl-C @REDRIUL     const(x'2D');
Dcl-C @REDULBL     const(x'2E');
Dcl-C @TRQCS       const(x'30');
Dcl-C @TRQRICS     const(x'31');
Dcl-C @YLWCS       const(x'32');
Dcl-C @YLWRICS     const(x'33');
Dcl-C @TRQUL       const(x'34');
Dcl-C @TRQRIUL     const(x'35');
Dcl-C @YLWUL       const(x'36');
Dcl-C @PNK         const(x'38');
Dcl-C @PNKRI       const(x'39');
Dcl-C @BLU         const(x'3A');
Dcl-C @BLURI       const(x'3B');
Dcl-C @PNKUL       const(x'3C');
Dcl-C @PNKRIUL     const(x'3D');
Dcl-C @BLUUL       const(x'3E');
// Protect fields
Dcl-C @PROTECT     const(x'A0');
Dcl-C @PRGRN       const(x'A0');
Dcl-C @PRGRNRI     const(x'A1');
Dcl-C @PRWHT       const(x'A2');
Dcl-C @PRWHTRI     const(x'A3');
Dcl-C @PRGRNUL     const(x'A4');
Dcl-C @PRGRNULRI   const(x'A5');
Dcl-C @PRWHTUL     const(x'A6');
Dcl-C @PRND        const(x'A7');
Dcl-C @PRRED       const(x'A8');
Dcl-C @PRREDRI     const(x'A9');
Dcl-C @PRREDHI     const(x'AA');
Dcl-C @PRREDHIRI   const(x'AB');
Dcl-C @PRREDUL     const(x'AC');
Dcl-C @PRREDULRI   const(x'AD');
Dcl-C @PRREDULBL   const(x'AE');
Dcl-C @PRTRQCS     const(x'B0');
Dcl-C @PRTRQCSRI   const(x'B1');
Dcl-C @PRYLWCS     const(x'B2');
Dcl-C @PRWHTRICS   const(x'B3');
Dcl-C @PRTRQULCS   const(x'B4');
Dcl-C @PRTRQULRICS const(x'B5');
Dcl-C @PRYLWULCS   const(x'B6');
Dcl-C @PRPNK       const(x'B8');
Dcl-C @PRPNKRI     const(x'B9');
Dcl-C @PRBLU       const(x'BA');
Dcl-C @PRBLURI     const(x'BB');
Dcl-C @PRPNKUL     const(x'BC');
Dcl-C @PRPNKULRI   const(x'BD');
Dcl-C @PRBLUUL     const(x'BE');
