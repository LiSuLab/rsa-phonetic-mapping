"""
The same as the Matlab one, but ported to Python.
Not pretty, but should do the job.
"""

from pathlib import Path
from typing import List

import numpy
import mne
from scipy.io import loadmat


class Wildcards:
    beta_identifier = '[[betaIdentifier]]'
    subject_name = "[[subjectName]]"
    lr = "[[LR]]"
    mask_name = "[[maskName]]"


class UserOptions:
    """Ported from phoneticMappingOptions.m"""
    root_path = Path('/Volumes/Mordin/Work archives/2016-08-11 CBU Imaging/Lexpro/Analysis_Phonetic_mapping/CWD_win60lag100p')
    output_path = Path("/Volumes/Mordin/Lexpro/")
    beta_path = Path(f'/imaging/at03/NKG_Code_output/Version4_2/LexproMEG/'
                     f'3-single-trial-source-data/'
                     f'vert10242-smooth5-nodepth-eliFM-snr1-signed/'
                     f'{Wildcards.beta_identifier}')
    mask_path = Path(f'/imaging/cw04/CSLB/Lexpro/Masks/{Wildcards.mask_name}')
    analysis_name = "lexpro-fixed-feature-matrix"
    subject_names = [
        'meg08_0320',
        'meg08_0323',
        'meg08_0324',
        'meg08_0327',
        'meg08_0348',
        'meg08_0350',
        'meg08_0363',
        'meg08_0366',
        'meg08_0371',
        'meg08_0372',
        'meg08_0377',
        'meg08_0380',
        'meg08_0397',
        'meg08_0400',
        'meg08_0401',
        'meg08_0402',
    ]
    mask_names = ['STG_STS_HG-lh', 'STG_STS_HG-rh']
    mask_time_windows = [[0, 370], [0, 370]]
    target_resolution = 10_242
    temporal_downsample_rate = 1


def get_beta_correspondence() -> numpy.array:
    """Ported from lexproBetaCorrespondence.m"""
    beta_file_path = Path(UserOptions.output_path,
                          'Stimuli-Lexpro-MEG-Single-col.txt')
    with beta_file_path.open("r") as beta_file:
        beta_names = sorted(beta_file.readlines())
    n_conditions = len(beta_names)
    n_trials = 1
    betas = [
        [
            f"{Wildcards.subject_name}-{(condition_i*n_trials+trial_i)+1}-{Wildcards.lr}h.stc"
            for condition_i in range(n_conditions)
        ]
        for trial_i in range(n_trials)
    ]
    return numpy.array(betas, dtype=numpy.string_)


def direct_load(matfile_path, variable_name):
    """
    Loads the named variable `variable_name` from `matfile_path`.
    :param matfile_path:
    :param variable_name:
    :return:
    """
    mat = loadmat(matfile_path)
    return mat[variable_name]


def meg_mask_preparation_source() -> List[mne.Label]:
    """Ported from MEGMaskPreparation_source.m"""

    masks_filename = f"{UserOptions.analysis_name}_Masks.mat"

    # assert len(UserOptions.mask_names) == len(UserOptions.mask_time_windows)
    #
    # index_masks =
    #
    # for mask_i, mask in enumerate(UserOptions.mask_names):
    #     read_path = Path(UserOptions.mask_path.as_posix()
    #                      .replace(Wildcards.mask_name, mask) + '.label')
    #     label = mne.read_label(read_path)
    #
    #     suffix = mask[-2:].lower()
    #     if suffix == "lh":
    #         chi = "L"
    #     elif suffix == "rh":
    #         chi = "R"
    #     else:
    #         raise ValueError()
    #
    #     raise NotImplementedError()

    # Skip all that and just load what we already have
    index_masks = direct_load(Path(UserOptions.root_path, 'ImageData', masks_filename), 'indexMasks')[0]
    return [
        mne.Label(
            vertices=mask[0].squeeze(),
            hemi=f"{mask[1][0].lower()}h",
            name=mask[2][0],
        )
        for mask in index_masks
    ]


def combine_vertex_masks_source(masks: List[mne.Label], mask_name) -> List[mne.Label]:
    """Ported from combineVertexMasks_source.m"""
    masks_out = []
    for hemi in ["lh", "rh"]:
        masks_this_hemi = [
            mask
            for mask in masks
            if mask.hemi == hemi
        ]

        # any vertex in any mask without double-counting
        mask_vs_this_hemi = sorted(set(
            v
            for mask in masks_this_hemi
            for v in mask.vertices
        ))

        # cap at resolution
        mask_vs_this_hemi = [
            v
            for v in mask_vs_this_hemi
            if v <= UserOptions.target_resolution
        ]

        # store in new mask struct
        masks_out.append(mne.Label(
            vertices=mask_vs_this_hemi,
            hemi=hemi,
            name=f"{mask_name}_{hemi[0].lower()}",
        ))
    return masks_out


def convert_to_stc_metadata(stc, mask: mne.Label = None):
    """Ported from convertToSTCMetadata"""
    n_vertices_raw, n_timepoints_raw = stc.data.shape
    first_datapoint_time_raw = stc.tmin
    timestep_raw = stc.tstep
    assert n_vertices_raw >= UserOptions.target_resolution
    n_timepoints_downsampled = len(range(0, n_timepoints_raw, step=UserOptions.temporal_downsample_rate))
    time_step_downsampled = timestep_raw * UserOptions.temporal_downsample_rate
    first_datapoint_time_downsampled = first_datapoint_time_raw
    last_datapoint_time_downsampled = first_datapoint_time_downsampled + (n_timepoints_downsampled * time_step_downsampled)

    stc_out = mne.SourceEstimate(
        data=None,
        vertices=mask.vertices if mask is not None else numpy.array(range(UserOptions.target_resolution)),
        tmin=first_datapoint_time_downsampled,
        tstep=time_step_downsampled,
    )

    stc_out.tmax = last_datapoint_time_downsampled
    return stc_out


def resave_as_masked_stc():

    sl_masks = meg_mask_preparation_source()
    sl_masks = combine_vertex_masks_source(sl_masks, 'combined_mask')

    image_data_path = Path(UserOptions.root_path, "ImageData")
    stc_output_dir = Path(UserOptions.output_path, "ImageData_stc")

    beta_correspondence: numpy.array = get_beta_correspondence()
    n_sessions, n_conditions = beta_correspondence.shape

    for chi in list('lr'):
        for subject in UserOptions.subject_names:

            subject_mesh_path = Path(image_data_path,
                                     f"{UserOptions.analysis_name}"
                                     f"_{subject}"
                                     f"_{chi}h"
                                     f"_CorticalMeshes.mat")

            # Get metadata
            # Don't have access to the orginal source files any more, but since we just need this for the metadata,
            # and we know it was originally used to save these files, we can just load it from there.
            dummy_read_path = Path("/Volumes/Mordin/Work archives/2016-08-11 CBU Imaging/Lexpro/Analysis_Phonetic_mapping/CWD_win60lag100p/ImageData_stc/meg08_0320_sess-01_cond-006_masked.stc")
            loaded_dummy_data = mne.read_source_estimate(dummy_read_path.as_posix())
            stc_metadata = convert_to_stc_metadata(stc=loaded_dummy_data,
                                                   mask=sl_masks[chi])

            all_masked_data = direct_load(subject_mesh_path)

            for session_i in range(n_sessions):
                for condition_i in range(n_conditions):

                    # Save it!

                    stc_path = Path(
                        stc_output_dir,
                        f"{subject}_sess-{session_i:2d}_cond-{condition_i:2d}_masked-{chi}h.stc"
                    )

                    masked_data = all_masked_data[:, :, condition_i, session_i].squeeze()
                    stc_metadata.data=masked_data
                    stc_metadata.save(stc_path.as_posix())


if __name__ == '__main__':
    resave_as_masked_stc()
