from setuptools import setup, find_packages, Extension
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
import sys
if sys.version_info < (3,):
    sys.exit('Sorry, Python3 is required for gnmt.')
with open('requirements.txt') as f:
        reqs = f.read()

cat_utils = CUDAExtension(
                        name='seq2seq.pack_utils._C',
                        sources=['seq2seq/csrc/pack_utils.cpp', 'seq2seq/csrc/pack_utils_kernel.cu'],
                        extra_compile_args={
                                'cxx': ['-O2',],
#                                'nvcc':['--gpu-architecture=sm_61',],
                                'nvcc': ['-arch=sm_60', '-gencode=arch=compute_60,code=sm_60', '-gencode=arch=compute_61,code=sm_61', '-gencode=arch=compute_70,code=sm_70', '-gencode=arch=compute_75,code=sm_75', '-gencode=arch=compute_75,code=compute_75' ,]
                        }
)

setup(
    name='gnmt',
    version='0.5.0',
    description='GNMT',
    install_requires=reqs.strip().split('\n'),
    packages=find_packages(),
    ext_modules=[cat_utils],
    cmdclass={
                'build_ext': BuildExtension
    },
    test_suite='tests',
)
