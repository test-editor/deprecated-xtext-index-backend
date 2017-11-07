package org.testeditor.web.xtext.index.persistence

import java.io.File
import java.util.List
import javax.inject.Singleton
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.diff.DiffEntry
import org.eclipse.jgit.lib.ObjectId
import org.eclipse.jgit.treewalk.CanonicalTreeParser
import org.slf4j.LoggerFactory

@Singleton
class GitService {
	/* see http://git.system.local/projects/TMT/repos/zgen/browse/dsl/de.signaliduna.tmt.zeusx.dsl.persistence/src/de/signaliduna/tmt/zeusx/dsl/persistence/git/GitService.xtend#17,28,38,328-330,332,334,336-337,339,344-345,352-354 */
	static val logger = LoggerFactory.getLogger(GitService)

	protected Git git = null

	def void initRepository(File projectFolder) {
		git = Git.init.setDirectory(projectFolder).call
	}

	def List<DiffEntry> calculateDiff(String oldHeadCommit, String newHeadCommit) {
		return calculateDiff(ObjectId.fromString(oldHeadCommit), ObjectId.fromString(newHeadCommit))
	}

	private def List<DiffEntry> calculateDiff(ObjectId oldHead, ObjectId newHead) {
		logger.info("Calculating diff between old='{}' and new='{}'.", oldHead.getName, newHead.getName)
		val reader = git.repository.newObjectReader
		try {
			val oldTree = new CanonicalTreeParser => [reset(reader, oldHead)]
			val newTree = new CanonicalTreeParser => [reset(reader, newHead)]
			val diff = git.diff.setOldTree(oldTree).setNewTree(newTree).call
			logger.info("Calculated diff='{}'.", diff)
			return diff
		} finally {
			reader.close
		}
	}

}
