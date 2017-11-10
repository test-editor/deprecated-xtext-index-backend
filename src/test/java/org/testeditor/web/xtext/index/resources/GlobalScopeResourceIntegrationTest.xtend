package org.testeditor.web.xtext.index.resources

import java.io.InputStream
import java.util.List
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.XtextPackage
import org.junit.Test
import org.testeditor.tcl.TclPackage
import org.testeditor.web.xtext.index.resources.bitbucket.AbstractIntegrationTest

import static javax.ws.rs.core.Response.Status.INTERNAL_SERVER_ERROR
import static javax.ws.rs.core.Response.Status.OK
import static org.assertj.core.api.Assertions.assertThat

class GlobalScopeResourceIntegrationTest extends AbstractIntegrationTest {

	val macroCollectionCountForLargeIndex = 100
	val tclMacroCollectionRefContext = '''
		package pack
		
		# Context
		
		* Some Teststep
		Macro: 
	'''
	val tmlUri = "pack/MacroLib.tml"
	val tml = '''
		package pack
		
		# MacroLib
		
		## FirstMacro
		
			template = "code"
		
			Component: SomeComponent
			- Some fixture call
	'''

	val macroCollectionReference = EcoreUtil.getURI(TclPackage.eINSTANCE.macroTestStepContext_MacroCollection).toString

	@Test
	def void macroReferencedByTcl() {
		// given
		addFileToIndex(tmlUri, tml)

		// when
		val response = postGlobalScopeRequest(tclMacroCollectionRefContext, macroCollectionReference, 'tcl',
			'pack/context.tcl')
		val payload = deserializeIEObjectDescriptions(response.entity as InputStream)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(1)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib")
		]

	}

	/**
	 * The index does not actually require the context resource's content!
	 */
	@Test
	def void macroReferencedByTclWithoutContextContent() {
		// given
		addFileToIndex(tmlUri, tml)

		val context = null

		// when
		val response = postGlobalScopeRequest(context, macroCollectionReference, 'tcl', 'pack/context.tcl')
		val payload = deserializeIEObjectDescriptions(response.entity as InputStream)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(1)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib")
		]

	}

	@Test
	def void macroReferencedByTclOnLargeIndex() {
		// given
		addSeparateMacroCollectionToIndexTimes(macroCollectionCountForLargeIndex)

		// when
		val response = postGlobalScopeRequest(tclMacroCollectionRefContext, macroCollectionReference, 'tcl',
			'pack/context.tcl')
		val payload = deserializeIEObjectDescriptions(response.entity as InputStream)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
		assertThat(payload).satisfies [
			assertThat(it).isInstanceOf(List)
			assertThat(size).isEqualTo(macroCollectionCountForLargeIndex)
			assertThat(head.getEClass.name).isEqualTo("MacroCollection")
			assertThat(head.qualifiedName.toString).isEqualTo("MacroLib0")
			assertThat(last.qualifiedName.toString).isEqualTo("MacroLib" + (macroCollectionCountForLargeIndex - 1))
		]
	}

	@Test
	def void noResourceNoContentCompletion() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = "tsl"
		val contextURI = "example.tsl"
		val context = tclMacroCollectionRefContext

		// when
		val response = postGlobalScopeRequest(context, reference, contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
	}

	@Test
	def void noContentTypeFallsBackToFileExtension() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = null
		val contextURI = "example.tsl"
		val context = tclMacroCollectionRefContext

		// when
		val response = postGlobalScopeRequest(context, reference, contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(OK.statusCode)
	}

	@Test
	def void nullContextURICausesError() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = null
		val contextURI = null
		val context = tclMacroCollectionRefContext

		// when
		val response = postGlobalScopeRequest(context, reference, contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(INTERNAL_SERVER_ERROR.statusCode)
		assertThat((response.entity as InputStream).deserializeException.message).isEqualTo(
			"No context URI was provided (URI is null).")
	}

	@Test
	def void emptyContextURICausesError() {
		// given
		val reference = EcoreUtil.getURI(XtextPackage.eINSTANCE.grammar_UsedGrammars).toString
		val contentType = "tsl"
		val contextURI = ""
		val context = tclMacroCollectionRefContext

		// when
		val response = postGlobalScopeRequest(context, reference, contentType, contextURI)

		// then
		assertThat(response.status).isEqualTo(INTERNAL_SERVER_ERROR.statusCode)
		assertThat((response.entity as InputStream).deserializeException.message).isEqualTo(
			"Failed to create resource for URI '' of type 'tsl'.")
	}

}
