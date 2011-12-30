//===- Version.cpp - Clang Version Number -----------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file defines several version-related utility functions for Clang.
//
//===----------------------------------------------------------------------===//

#include "clang/Basic/Version.h"
#include "clang/Basic/LLVM.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Config/config.h"
#include <cstring>
#include <cstdlib>

namespace clang {
  
std::string getClangRepositoryPath() {
#if defined(CLANG_REPOSITORY_STRING)
  return CLANG_REPOSITORY_STRING;
#else
#ifdef SVN_REPOSITORY
  StringRef URL(SVN_REPOSITORY);
#else
  StringRef URL("");
#endif

  // If the SVN_REPOSITORY is empty, try to use the SVN keyword. This helps us
  // pick up a tag in an SVN export, for example.
  static StringRef SVNRepository("$URL: http://llvm.org/svn/llvm-project/cfe/tags/RELEASE_30/final/lib/Basic/Version.cpp $");
  if (URL.empty()) {
    URL = SVNRepository.slice(SVNRepository.find(':'),
                              SVNRepository.find("/lib/Basic"));
  }

  // Strip off version from a build from an integration branch.
  URL = URL.slice(0, URL.find("/src/tools/clang"));

  // Trim path prefix off, assuming path came from standard cfe path.
  size_t Start = URL.find("cfe/");
  if (Start != StringRef::npos)
    URL = URL.substr(Start + 4);

  return URL;
#endif
}

std::string getClangRevision() {
#ifdef SVN_REVISION
  return SVN_REVISION;
#else
  return "";
#endif
}

std::string getClangFullRepositoryVersion() {
  std::string buf;
  llvm::raw_string_ostream OS(buf);
  std::string Path = getClangRepositoryPath();
  std::string Revision = getClangRevision();
  if (!Path.empty())
    OS << Path;
  if (!Revision.empty()) {
    if (!Path.empty())
      OS << ' ';
    OS << Revision;
  }
  return OS.str();
}
  
std::string getClangFullVersion() {
  std::string buf;
  llvm::raw_string_ostream OS(buf);
#ifdef CLANG_VENDOR
  OS << CLANG_VENDOR;
#endif
  OS << "clang version " CLANG_VERSION_STRING " ("
     << getClangFullRepositoryVersion() << ')';

#ifdef CLANG_VENDOR_SUFFIX
  OS << CLANG_VENDOR_SUFFIX;
#elif defined(CLANG_VENDOR)
  // If vendor supplied, include the base LLVM version as well.
  OS << " (based on LLVM " << PACKAGE_VERSION << ")";
#endif

  return OS.str();
}

std::string getClangFullCPPVersion() {
  // The version string we report in __VERSION__ is just a compacted version of
  // the one we report on the command line.
  std::string buf;
  llvm::raw_string_ostream OS(buf);
#ifdef CLANG_VENDOR
  OS << CLANG_VENDOR;
#endif
  OS << "Clang " CLANG_VERSION_STRING " ("
     << getClangFullRepositoryVersion() << ')';
  return OS.str();
}

} // end namespace clang
