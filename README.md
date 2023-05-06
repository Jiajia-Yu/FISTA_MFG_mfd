# FISTA_MFG_mfd
This repository contains MATLAB implementations of FISTA for MFG on triangular meshes representation of two-dimensional manifolds ([Yu et al. 2023](https://github.com/Jiajia-Yu/FISTA_MFP_euc/blob/main/README.md#reference)).

Self-generated triangular meshes used in the paper are available in the ``Data`` folder.

All codes are in the ``code`` folder. 

  ``test_xxx.m`` are the main scripts to regenerate the results in the paper.
 
  ``readOFF.m``, ``getaroundpt.m``, ``surfOperators.m``, ``surfOperators4d.m`` and ``surfOperators5d.m`` are for preprocessing the triangular meshes.

  ``mfgMfFista.m`` and ``mfpMfFista.m`` are the main functions to solve MFG/MFP problems on the triangular meshes.

  ``dctMfg.m`` and ``idctMfg.m`` are the functions to solve the projection for MFG problems on the triangular meshes.

  ``viewMesh.m`` and ``viewVectF.m`` are for visualizing the results.
  
Due to legacy issues, the naming of functions and variables has not followed a unified convention. We apologize for any inconvenience this may cause.

## Reference

Jiajia Yu, Rongjie Lai, Wuchen Li and Stanley Osher. [Computational Mean-Field Games on Manifolds.](https://doi.org/10.1016/j.jcp.2023.112070) Journal of Computational Physics 484 (2023): 112070.
