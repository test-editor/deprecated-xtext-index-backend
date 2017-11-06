package org.testeditor.web.xtext.index

import com.google.inject.Binder
import org.eclipse.xtext.AbstractXtextRuntimeModule
import org.eclipse.xtext.resource.IResourceDescriptions

class XtextIndexModule extends AbstractXtextRuntimeModule {

	override void configureIResourceDescriptions(Binder binder) {
		binder.bind(IResourceDescriptions).to(XtextIndex)
	}

}
