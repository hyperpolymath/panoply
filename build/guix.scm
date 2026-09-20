;; SPDX-License-Identifier: MPL-2.0
;; Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
;;
;; Guix package for panoply (library: Zig FFI tests; Idris2 optional).
;;   guix shell -D -f build/guix.scm
;;   guix build -f build/guix.scm
;;
;; Guix's zig package may lag 0.15.1 (mise pin). If check fails on version,
;; use the Containerfile tarball or mise — do not silently skip tests.

(use-modules (guix packages)
             (guix gexp)
             (guix build-system gnu)
             (guix licenses)
             (gnu packages zig)
             (gnu packages commencement))

(package
  (name "panoply")
  (version "0.1.0")
  (source (local-file ".." "source"
                       #:recursive? #t
                       #:select? (lambda (file stat)
                                   (not (string-contains file ".git")))))
  (build-system gnu-build-system)
  (arguments
   '(#:tests? #t
     #:phases
     (modify-phases %standard-phases
       (delete 'configure)
       (replace 'build
         (lambda _
           (with-directory-excursion "src/interface/ffi"
             (invoke "zig" "build"))))
       (replace 'check
         (lambda _
           (with-directory-excursion "src/interface/ffi"
             (invoke "zig" "build" "test"))))
       (replace 'install
         (lambda* (#:key outputs #:allow-other-keys)
           (let ((out (assoc-ref outputs "out")))
             (mkdir-p (string-append out "/share/doc/panoply"))
             (copy-file "README.adoc"
                        (string-append out "/share/doc/panoply/README.adoc"))))))))
  (native-inputs (list zig gcc-toolchain))
  (home-page "https://github.com/hyperpolymath/panoply")
  (synopsis "Envelope-first language discipline (Idris2 ABI + Zig FFI)")
  (description "Panoply is a library, not a server. This package runs the
Zig FFI test build. Idris2 ABI typecheck is optional and not a Guix input
until a channel pin exists.")
  (license mpl2.0))
