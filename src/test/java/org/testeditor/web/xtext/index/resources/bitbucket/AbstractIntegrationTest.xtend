package org.testeditor.web.xtext.index.resources.bitbucket

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.google.inject.Guice
import com.google.inject.util.Modules
import io.dropwizard.testing.ResourceHelpers
import io.dropwizard.testing.junit.DropwizardAppRule
import java.io.File
import javax.ws.rs.client.Invocation
import org.eclipse.emf.common.util.URI
import org.eclipse.jgit.junit.JGitTestUtil
import org.eclipse.xtext.scoping.IGlobalScopeProvider
import org.junit.After
import org.junit.ClassRule
import org.junit.Rule
import org.junit.rules.TemporaryFolder
import org.testeditor.aml.dsl.AmlStandaloneSetup
import org.testeditor.tcl.dsl.TclStandaloneSetup
import org.testeditor.tsl.dsl.TslRuntimeModule
import org.testeditor.tsl.dsl.web.TslWebSetup
import org.testeditor.web.xtext.index.XtextIndex
import org.testeditor.web.xtext.index.XtextIndexApplication
import org.testeditor.web.xtext.index.XtextIndexModule

import static io.dropwizard.testing.ConfigOverride.config

class AbstractIntegrationTest {

	public static class TestXtextIndexApplication extends XtextIndexApplication {
		val tslWebSetup = new TslWebSetup
		val injector = Guice.createInjector(Modules.override(new TslRuntimeModule).with(new XtextIndexModule))
		val index = injector.getInstance(XtextIndex) // construct index with language injector

		override getLanguageSetups() {
			return #[tslWebSetup, new TclStandaloneSetup, new AmlStandaloneSetup]
		}

		override getGuiceInjector() {
			return injector
		}

	}

	@ClassRule
	public static val temporaryFolder = new TemporaryFolder

	@Rule
	public val dropwizardRule = new DropwizardAppRule(TestXtextIndexApplication,
		ResourceHelpers.resourceFilePath("config.yml"), #[
			config('repoLocation', temporaryFolder.root.absolutePath),
			config('logging.level', 'TRACE')
		])

//	static var Repository repo
//	static var Git git
//	@BeforeClass
//	public static def void createEmptyRepo() {
//		Git.init.setDirectory(temporaryFolder.root).call
//		repo = new FileRepository(temporaryFolder.root)
//		git = Git.open(temporaryFolder.root)
//		// pull will fail but this is not relevant for the test and can be ignored
//	}

	protected def void addFileToIndex(String fileName, String content) {
		val file = new File(temporaryFolder.root, fileName)
		JGitTestUtil.write(file, content)
		(dropwizardRule.application as TestXtextIndexApplication).indexInstance.add(
			URI.createFileURI(file.absolutePath))
	}

//	protected def void commit(String message) {
//		git.commit.setMessage(message).call
//	}
	@After
	public def void cleanupTempFolder() {
		// since temporary folder is a class rule (to make sure it is run before the dropwizard rul),
		// cleanup all contents of the temp folder without deleting it itself
		recursiveDelete(temporaryFolder.root, false)
	}

	protected def String getToken() {
		val builder = JWT.create => [
			withClaim('id', 'john.doe')
			withClaim('name', 'John Doe')
			withClaim('email', 'john@example.org')
		]
		return builder.sign(Algorithm.HMAC256("secret"))
	}

	protected def Invocation.Builder authHeader(Invocation.Builder builder) {
		builder.header('Authorization', '''Bearer «token»''')
		return builder
	}

	protected def void recursiveDelete(File file, boolean deleteThis) {
		file.listFiles?.forEach[recursiveDelete(true)]
		if(deleteThis) {
			file.delete
		}
	}
}
