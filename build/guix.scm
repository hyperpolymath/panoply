;; SPDX-License-Identifier: MPL-2.0
;; Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
;;
;; Guix package definition for Panoply
;;
;; Usage:
;;   guix shell -D -f guix.scm    # Enter development shell
;;   guix build -f guix.scm       # Build package
;;
;; TODO: wire real build/check phases and native/runtime inputs once the
;; Core/Evidence/Manifest artefacts land (currently text-level placeholders
;; only — no guix toolchain was available locally to verify a real build).
;; See: https://guix.gnu.org/manual/en/html_node/Defining-Packages.html

(use-modules (guix packages)
             (guix gexp)
             (guix git-download)
             (guix build-system gnu)
             (guix licenses)
             (gnu packages base))

(package
  (name "panoply")
  (version "0.1.0")
  (source (local-file "." "source"
                       #:recursive? #t
                       #:select? (lambda (file stat)
                                   (not (string-contains file ".git")))))
  (build-system gnu-build-system)
  (arguments
   '(#:phases
     (modify-phases %standard-phases
       ;; TODO: Customize build phases for your project
       ;; Examples for common stacks:
       ;;
       ;; Rust:
       ;;   (replace 'build (lambda _ (invoke "cargo" "build" "--release")))
       ;;   (replace 'check (lambda _ (invoke "cargo" "test")))
       ;;
       ;; Elixir:
       ;;   (replace 'build (lambda _ (invoke "mix" "compile")))
       ;;   (replace 'check (lambda _ (invoke "mix" "test")))
       ;;
       ;; Zig:
       ;;   (replace 'build (lambda _ (invoke "zig" "build")))
       ;;   (replace 'check (lambda _ (invoke "zig" "build" "test")))
       (delete 'configure)
       (delete 'build)
       (delete 'check)
       (replace 'install
         (lambda* (#:key outputs #:allow-other-keys)
           (let ((out (assoc-ref outputs "out")))
             (mkdir-p (string-append out "/share/doc"))
             (copy-file "README.adoc"
                        (string-append out "/share/doc/README.adoc"))))))))
  (native-inputs
   (list
    ;; TODO: Add build-time dependencies
    ;; Examples:
    ;;   rust (gnu packages rust)
    ;;   elixir (gnu packages elixir)
    ;;   zig (gnu packages zig)
    ))
  (inputs
   (list
    ;; TODO: Add runtime dependencies
    ))
  (home-page "https://github.com/hyperpolymath/panoply")
  (synopsis "An envelope-first language discipline: every safety claim explicit, scoped, inspectable, and mechanically accountable.")
  (description "Panoply is defined by three artefacts: a checked Core into
which every accepted program projects, explicit evidence for the claims a
program makes, and a safety-envelope manifest recording which guarantees
have been earned and which have not.  It is not yet feature-complete; the
Core checker, evidence formats, manifest schema, and backend contracts
named by the charter are still being built.  See README.adoc and
docs/architecture/DESIGN-DISCIPLINE.adoc for details.")
  (license (list
            ;; MPL-2.0 extends MPL-2.0
            mpl2.0)))
