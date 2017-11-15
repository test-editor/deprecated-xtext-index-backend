package org.testeditor.web.xtext.index

import com.google.inject.AbstractModule
import org.eclipse.xtext.resource.IResourceDescriptions

/**
 * guice module binding XtextIndex
 */
class XtextIndexModule extends AbstractModule {
	
	override protected configure() {
		binder.bind(IResourceDescriptions).to(XtextIndex)
	}

}
