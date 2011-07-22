#ifndef LLVM_TARGET_IA64_INSTPRINTER_H
#define LLVM_TARGET_IA64_INSTPRINTER_H

#include "llvm/MC/MCInstPrinter.h"

namespace llvm {

  class MCOperand;

  class IA64InstPrinter : public MCInstPrinter {
  public:
    IA64InstPrinter(const MCAsmInfo &MAI) :
        MCInstPrinter(MAI) {}

    virtual void printInst(const MCInst *MI, raw_ostream &O);

    // Autogenerated by tblgen.
    void printInstruction(const MCInst *MI, raw_ostream &O);
    static const char *getRegisterName(unsigned RegNo);

    void printOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O,
          const char *Modifier = 0);
    void printPCRelImmOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
    void printSrcMemOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O,
          const char *Modifier = 0);
    void printCCOperand(const MCInst *MI, unsigned OpNo, raw_ostream &O);
  };

} // namespace llvm

#endif // LLVM_TARGET_IA64_INSTPRINTER_H
