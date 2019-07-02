/**
 * \file metis_pmmg.h
 * \brief metis_pmmg.c header file
 * \author Cécile Dobrzynski (Bx INP/Inria)
 * \author Algiane Froehly (Inria)
 * \version 5
 * \copyright GNU Lesser General Public License.
 */

#ifndef METIS_PMMG_H

#define METIS_PMMG_H

#include "parmmg.h"
#include <metis.h>

#ifdef USE_PARMETIS
#include <parmetis.h>
#endif

/* Available choices for the wgtflag parameter of ParMetis */
#define PMMG_WGTFLAG_NONE  0
#define PMMG_WGTFLAG_ADJ   1
#define PMMG_WGTFLAG_VTX   2
#define PMMG_WGTFLAG_BOTH  3

/**
 * \def PMMG_WGTFLAG_DEF
 *
 * value for the wgtflag parameter of ParMetis
 *
 */
#define PMMG_WGTFLAG_DEF   (PMMG_WGTFLAG_ADJ)

/**
 * \def PMMG_WGTVAL_HUGEINT
 *
 * Huge integer weight for parallel faces in load balancing
 *
 */
#define PMMG_WGTVAL_HUGEINT   1000000

/**
 * \def PMMG_UBVEC_DEF
 *
 * value for the ubvec vector of ParMetis
 *
 */
#define PMMG_UBVEC_DEF     1.05

/**
 * \def PMMG_CONTIG_DEF
 *
 * value for option[METIS_OPTION_CONTIG] in Metis
 *
 */
#define PMMG_CONTIG_DEF     0


/**
 * \def PMMG_NBADJA_GRPS
 *
 * Supposed maximum number of groups adjacent to one given group
 *
 */
#define PMMG_NBADJA_GRPS   30

/**
 * \struct PMMG_hgrp
 *
 * \brief Cell of the hastable HGrp
 *
 */
typedef struct {
  idx_t   adj; /*!< item to add */
  idx_t   wgt; /*!< Edge weight */
  int     nxt; /*!< Next element of the linked list */
} PMMG_hgrp;

/**
 * \struct PMMG_HGrp
 *
 * \brief Hash table to store the list of adjacents groups to a given group.
 *
 */
typedef struct {
  int          siz,max,nxt;
  PMMG_hgrp    *item;
} PMMG_HGrp;

int PMMG_checkAndReset_grps_contiguity( PMMG_pParMesh parmesh );
int PMMG_check_grps_contiguity( PMMG_pParMesh parmesh );
int PMMG_graph_meshElts2metis(PMMG_pParMesh,MMG5_pMesh,MMG5_pSol,idx_t**,idx_t**,idx_t**,idx_t*,size_t*);
int PMMG_part_meshElts2metis( PMMG_pParMesh,idx_t*,idx_t);
int PMMG_graph_parmeshGrps2parmetis(PMMG_pParMesh,idx_t**,idx_t**,idx_t**,idx_t*,
                                    idx_t**,idx_t**,idx_t*,idx_t*,idx_t*,idx_t,
                                    real_t**,real_t**);
int PMMG_part_parmeshGrps2parmetis(PMMG_pParMesh,idx_t*,idx_t);
int PMMG_part_parmeshGrps2metis(PMMG_pParMesh,idx_t*,idx_t);
int PMMG_correct_parmeshGrps2parmetis( PMMG_pParMesh parmesh, idx_t *vtxdist,
                                       idx_t* mypart,idx_t nproc );

#endif
