package org.testeditor.web.xtext.index

import javax.inject.Inject
import org.slf4j.LoggerFactory
import org.testeditor.web.xtext.index.persistence.GitDiffXtextIndexTranslator
import org.testeditor.web.xtext.index.persistence.GitService
import org.testeditor.web.xtext.index.resources.PushEventGitInfos
import org.testeditor.web.xtext.index.resources.RepoEvent
import org.testeditor.web.xtext.index.resources.RepoEventCallback
import org.eclipse.xtend.lib.annotations.Accessors

class PushEventIndexUpdateCallback implements RepoEventCallback {

	protected static val logger = LoggerFactory.getLogger(PushEventGitInfos)

	@Inject PushEventGitInfos gitInfos
	@Inject GitDiffXtextIndexTranslator translator
	@Inject GitService gitService

	@Accessors(PUBLIC_SETTER)
	XtextIndex index

	override call(RepoEvent event) {
		if (gitInfos.isPushEvent(event)) {
			val oldNewCommits = gitInfos.getOldNewHeadCommitIds(event)
			logger.info("processing push event with old,new-commits='{}'", oldNewCommits)
			val diffs = gitService.calculateDiff(oldNewCommits.first, oldNewCommits.second)
			translator.execute(diffs, index)
		} else {
			logger.warn("ignoring event (not identified as push event) ='{}'", event.nativeEventPayload)
		}
	}

}
