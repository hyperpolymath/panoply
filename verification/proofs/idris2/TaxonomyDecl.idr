-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- Local taxonomy declaration. Does not vendor proven-tests-and-benches.
-- Category 18 (coupling) is ABI↔FFI Result tags (tests/p2p.sh).

module TaxonomyDecl

%default total

public export
data Applicability = Present | HonestNA

public export
record Cat where
  constructor MkCat
  code : String
  status : Applicability

||| Eighteen taxonomy categories. Present = an artefact exists in-tree.
public export
categories : List Cat
categories =
  [ MkCat "UT"  Present
  , MkCat "P2P" Present
  , MkCat "E2E" Present
  , MkCat "BLD" Present
  , MkCat "EXE" HonestNA
  , MkCat "REF" Present
  , MkCat "LCY" Present
  , MkCat "SMK" Present
  , MkCat "PBT" HonestNA
  , MkCat "MUT" HonestNA
  , MkCat "FUZ" HonestNA
  , MkCat "CTR" HonestNA
  , MkCat "REG" HonestNA
  , MkCat "CHS" HonestNA
  , MkCat "CMP" HonestNA
  , MkCat "PRF" Present
  , MkCat "TSF" HonestNA
  , MkCat "CDF" Present
  ]

public export
categoryCount : Nat
categoryCount = length categories

export
eighteenCategories : TaxonomyDecl.categoryCount = 18
eighteenCategories = Refl
