from setuptools import setup, find_packages, Extension

with open("README.md", "r") as f:
    long_description = f.read()

setup(
    name="aoutil",
    version='0.1.1.0',
    author="a24ma",
    author_email="62923767+a24ma@users.noreply.github.com",
    description="aoutil is my own python utilities.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/a24ma/aoutil",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        'Operating System :: Microsoft :: Windows',
        "Operating System :: MacOS",
        "Operating System :: POSIX :: Linux",
    ]
)
