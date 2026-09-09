# Source 2.0 draft-history rewrite

This record maps the unpublished Source 2.0 draft onto the owner-approved
modernization branch. Local `main` at
`f6d43ae62676bd715e4aea65b350e277aadba1c9` was the immutable base. The rewrite
preserves the established architectural boundaries and prevents modified files
from creating new historical copies of legacy review metadata.

| Previous commit | Replacement commit | Scope | Reason |
| --- | --- | --- | --- |
| `0d7875881571dcf073acc7e2baad6c4f00f28a4c` | `3b9d2d3996652eeda0859dca28e0abe38f2af0ad` | Correct the checksum-error documentation link. | Preserve the one-file change while recording the current co-author accurately. |
| `3bb9ca0ebbc492070ef4ce1eee7a92150bba18a8` | `48f7cf33a63a1bcbf6eb35bf9c3c82995ea871c1` | Reconstruct the Z80 driver and sound data. | Replay the complete atomic subsystem change onto the approved base. |
| `e911d088d9c9af49cdeae0878552855921d568c0` | `21ef9a61ac1ec19c7b8267794e00d0168e511709` | Isolate content authoring. | Preserve the build boundary and zero-edit identity evidence. |
| `fc9b3f856390571589d2d5d5f388d1967e335aee` | `a4ab2bc40527093cb3a92cbd579846384ce55c2e` | Add level authoring and Level Studio. | Preserve one complete editor-model vertical slice. |
| `8227525f7b3635c1beb99330c843f7f4703188d2` | `3b8bae981c2bcef5e9856f2ec4374a284b8affcf` | Add graphics authoring and adopt project-owned release metadata. | Keep the codec, model, GUI, and test boundary while removing legacy provenance before changed files create new draft blobs. |
| `7d16bd7f68161d660f77d9ad2773ab850c9d0c15` | `8ef5dc659b3976add53482a881f6caef71e0d02f` | Add music, SFX, and FM voice authoring. | Preserve the semantic sound-authoring boundary. |
| `d51297d3a15364ef6a2a649dd3b921cc9b31b5d1` | `e97922e28d74f534b68fceb111a629ec44f09464` | Define the Source 2.0 project gate. | Preserve the first complete machine-readable acceptance boundary. |
| `ddf6a5c9537ee553e435db1588fc44c570c1df66` | `d4408d3aeebaef2b0eca0f1cadd1f92f6256d2a1` | Organize assembly by semantic owner. | Preserve the address-safe source reorganization as one reviewable change. |
| `d838db42acc3855c1419a902ffdaf60c0304a048` | `781cc83d13544b98fc9a64b9e070023f7353c355` | Organize scripts by responsibility. | Keep moves, imports, subprocess paths, and tests atomic. |
| `6c153b1f5c2491b622540e0467d354532942c352` | `f56a3fa9a2e781642893d9f86061b4e0daf3bda8` | Complete Level Studio rendering and playtesting. | Preserve the editor-to-runtime vertical slice. |
| `7ccca4955f2ae494081025083405ceec92cdd175` | `57cd95f81b4f497cee3e9a1778c4635debe8fb9e` | Add standalone sound preview and trace comparison. | Preserve the sequencer, renderer, toolchain, and fidelity evidence together. |
| `696702e95e8f5871fe50ee14b982771ecd1c071c` | `dd3703ce59611bbc9e61aee0708d1ab0784488d7` | Match Level Studio to VDP presentation. | Preserve the focused visual-correctness fix and regressions. |
| `fc1d2bc33d4e7dc0e2e05cd9525e876fcfef7f6b` | `0a7ba8434c7b7d017621a24f269dc760c411e708` | Modernize repository layout and the public release interface. | Combine the structural draft with the current project-owned manifest and audit policy so legacy review provenance is absent from the candidate tree. |

All replacements are nonempty. AuthorDate and CommitDate are monotonic in
parent order. Direct replays keep their original timestamps; combined cleanup
uses a timestamp inside the interval between the represented draft and the
current correction.

The remote-tracked baseline remains unchanged. Its historical release-policy
metadata, together with old local branches and tags, is deliberately outside
this rewrite. Any coordinated cleanup or ref removal is deferred to explicit
owner review; this branch neither rewrites published objects nor deletes local
recovery refs.
