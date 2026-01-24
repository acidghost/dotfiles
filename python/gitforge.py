"""
gitforge - Shared library for git forge (GitHub/GitLab/Bitbucket) URL generation.

Provides utilities for:
- Finding git repository roots
- Parsing remote URLs
- Building web URLs for files in repositories
"""

from __future__ import annotations

import re
import subprocess
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Literal


@dataclass(frozen=True)
class GitRepoInfo:
    """Cached git repository information."""

    root_path: Path
    remote_url: str
    ref: str  # The ref used in URLs (commit or branch)
    commit: str  # Always the commit hash
    branch: str | None  # Symbolic ref, None if detached HEAD
    host_type: Literal["github", "gitlab", "bitbucket", "unknown"]
    base_web_url: str


@lru_cache(maxsize=1024)
def find_git_root(file_path: Path) -> Path | None:
    """
    Find the git repository root for a file.

    Walks up directory tree to find .git directory.
    Results are cached to avoid repeated filesystem checks.
    """
    current = file_path.resolve()

    # If it's a file, start from its parent directory
    if current.is_file():
        current = current.parent

    while current != current.parent:
        if (current / ".git").exists():
            return current
        current = current.parent

    # Check root directory too
    if (current / ".git").exists():
        return current

    return None


def run_git_command(git_root: Path, *args: str) -> str | None:
    """Run a git command in the given repository root."""
    try:
        result = subprocess.run(
            ["git", "-C", str(git_root), *args],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def parse_remote_url(url: str) -> tuple[str, str, str] | None:
    """
    Parse a git remote URL.

    Handles:
    - SSH format: git@github.com:user/repo.git
    - HTTPS format: https://github.com/user/repo.git

    Returns (host, user, repo) or None.
    """
    # SSH format: git@github.com:user/repo.git
    ssh_match = re.match(r"^git@([^:]+):([^/]+)/(.+?)(?:\.git)?$", url)
    if ssh_match:
        return ssh_match.groups()  # type: ignore

    # HTTPS format: https://github.com/user/repo.git
    https_match = re.match(r"^https?://([^/]+)/([^/]+)/(.+?)(?:\.git)?$", url)
    if https_match:
        return https_match.groups()  # type: ignore

    return None


def detect_host_type(host: str) -> Literal["github", "gitlab", "bitbucket", "unknown"]:
    """Detect the hosting service from hostname."""
    host_lower = host.lower()
    if "github" in host_lower:
        return "github"
    elif "gitlab" in host_lower:
        return "gitlab"
    elif "bitbucket" in host_lower:
        return "bitbucket"
    return "unknown"


def build_base_web_url(
    host: str,
    user: str,
    repo: str,
    host_type: Literal["github", "gitlab", "bitbucket", "unknown"],
) -> str:
    """Build the base web URL for a repository."""
    # Handle enterprise instances (e.g., github.mycompany.com)
    if host_type == "github":
        return f"https://{host}/{user}/{repo}"
    elif host_type == "gitlab":
        return f"https://{host}/{user}/{repo}"
    elif host_type == "bitbucket":
        return f"https://{host}/{user}/{repo}"
    else:
        # Default to GitHub-style for unknown
        return f"https://{host}/{user}/{repo}"


@lru_cache(maxsize=128)
def _get_repo_info_cached(
    git_root: Path, use_branch: bool
) -> GitRepoInfo | None:
    """
    Get repository information for a git root (cached implementation).

    Runs git commands to get remote URL, branch, and commit.
    Results are cached per (repository, use_branch) pair.
    """
    # Get remote URL
    remote_url = run_git_command(git_root, "config", "--get", "remote.origin.url")
    if not remote_url:
        return None

    # Parse remote URL
    parsed = parse_remote_url(remote_url)
    if not parsed:
        return None

    host, user, repo = parsed

    # Always get commit hash
    commit = run_git_command(git_root, "rev-parse", "HEAD")
    if not commit:
        return None

    # Try to get symbolic branch name
    branch = run_git_command(git_root, "symbolic-ref", "--short", "HEAD")

    # Determine ref for URLs: use branch if requested and available, else commit
    if use_branch and branch:
        ref = branch
    else:
        ref = commit

    host_type = detect_host_type(host)
    base_web_url = build_base_web_url(host, user, repo, host_type)

    return GitRepoInfo(
        root_path=git_root,
        remote_url=remote_url,
        ref=ref,
        commit=commit,
        branch=branch,
        host_type=host_type,
        base_web_url=base_web_url,
    )


def get_repo_info(git_root: Path, use_branch: bool = False) -> GitRepoInfo | None:
    """
    Get repository information for a git root.

    Args:
        git_root: Path to the git repository root.
        use_branch: If True, use branch name in URLs (if available).
                    If False (default), use commit hash for stable permalinks.

    Returns:
        GitRepoInfo with repository details, or None if not available.
    """
    return _get_repo_info_cached(git_root, use_branch)


def build_file_url(
    repo_info: GitRepoInfo, relative_path: Path, line: int | None
) -> str:
    """
    Build a URL to view a file in the online repository.

    Different hosting services have different URL formats:
    - GitHub: https://github.com/user/repo/blob/ref/path#L42
    - GitLab: https://gitlab.com/user/repo/-/blob/ref/path#L42
    - Bitbucket: https://bitbucket.org/user/repo/src/ref/path#lines-42
    """
    path_str = str(relative_path)

    if repo_info.host_type == "github":
        url = f"{repo_info.base_web_url}/blob/{repo_info.ref}/{path_str}"
        if line is not None:
            url += f"#L{line}"
    elif repo_info.host_type == "gitlab":
        url = f"{repo_info.base_web_url}/-/blob/{repo_info.ref}/{path_str}"
        if line is not None:
            url += f"#L{line}"
    elif repo_info.host_type == "bitbucket":
        url = f"{repo_info.base_web_url}/src/{repo_info.ref}/{path_str}"
        if line is not None:
            url += f"#lines-{line}"
    else:
        # Default to GitHub-style
        url = f"{repo_info.base_web_url}/blob/{repo_info.ref}/{path_str}"
        if line is not None:
            url += f"#L{line}"

    return url
