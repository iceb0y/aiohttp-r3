from Cython.Build import cythonize
from os import chdir, path
from setuptools import setup
from setuptools.command.build_ext import build_ext
from setuptools.extension import Extension

class BuildR3Extension(build_ext):
    def run(self):
        root_dir = path.abspath(path.dirname(__file__))
        chdir('deps/r3')
        try:
            if not path.exists('Makefile'):
                if not path.exists('configure'):
                    self.spawn(['./autogen.sh'])
                self.spawn(['./configure', '--enable-shared=false', '--with-pic'])
            self.spawn(['make'])
        finally:
            chdir(root_dir)
        self.include_dirs.append('deps/r3/include')
        self.library_dirs.append('deps/r3/.libs')
        return build_ext.run(self)

setup(
    name = "aiohttp-r3",
    version = '0.0.3',
    description = 'R3 router for aiohttp',
    url = 'https://github.com/iceb0y/aiohttp-r3',
    author = 'iceboy',
    author_email = 'me\x40iceboy.org',
    license = 'Apache 2',
    packages = ['aiohttp_r3'],
    install_requires = open('requirements.txt').readlines(),
    ext_modules = cythonize([
        Extension(
            'aiohttp_r3._r3',
            ['aiohttp_r3/_r3.pyx'],
            libraries=['r3', 'pcre'],
        ),
    ]),
    cmdclass = {'build_ext': BuildR3Extension},
)
